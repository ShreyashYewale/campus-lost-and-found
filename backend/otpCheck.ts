import { graphql } from '@keystone-6/core';
import { type KeystoneContext } from '@keystone-6/core/types';
 
// Adds a custom mutation:  verifyClaimOtp(claimId, code)
// The finder enters the code the claimant shows them. If it matches and hasn't
// expired, the claim is marked verified and the underlying item is resolved.
export const extendGraphqlSchema = graphql.extend((base) => {
  return {
    mutation: {
      verifyClaimOtp: graphql.field({
        type: graphql.object<{ success: boolean; message: string }>()({
          name: 'VerifyClaimOtpResult',
          fields: {
            success: graphql.field({ type: graphql.nonNull(graphql.Boolean) }),
            message: graphql.field({ type: graphql.nonNull(graphql.String) }),
          },
        }),
        args: {
          claimId: graphql.arg({ type: graphql.nonNull(graphql.ID) }),
          code: graphql.arg({ type: graphql.nonNull(graphql.String) }),
        },
        async resolve(_source, { claimId, code }, context: KeystoneContext) {
          const sudo = context.sudo();
 
          const claim = await sudo.db.Claim.findOne({ where: { id: String(claimId) } });
          if (!claim) {
            return { success: false, message: 'Claim not found.' };
          }
          if (claim.status !== 'approved') {
            return { success: false, message: 'This claim has not been approved yet.' };
          }
          if (claim.otpVerified) {
            return { success: false, message: 'This claim has already been verified.' };
          }
          if (!claim.otpCode) {
            return { success: false, message: 'No OTP was generated for this claim.' };
          }
          if (claim.otpExpiresAt && new Date(String(claim.otpExpiresAt)) < new Date()) {
            return { success: false, message: 'The OTP has expired. Please re-approve the claim.' };
          }
          if (String(code).trim() !== String(claim.otpCode).trim()) {
            return { success: false, message: 'Incorrect OTP. Please try again.' };
          }
 
          // Success: mark the claim verified and resolve the item.
          await sudo.db.Claim.updateOne({
            where: { id: String(claimId) },
            data: { otpVerified: true },
          });
 
          if (claim.itemId) {
            await sudo.db.Item.updateOne({
              where: { id: String(claim.itemId) },
              data: { status: 'resolved' },
            });
          }
 
          return { success: true, message: 'OTP verified. Item marked as resolved.' };
        },
      }),
    },
  };
});