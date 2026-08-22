type Session = {
  itemId?: string;
  listKey?: string;
  data?: {
    id?: string;
    name?: string;
  };
};

export const isLoggedIn = ({ session }: { session?: Session }) => !!session?.itemId;

export const isOwner = ({
  session,
  item,
}: {
  session?: Session;
  item?: { postedById?: string | null };
}) => !!session?.itemId && session.itemId === item?.postedById;

export const isClaimant = ({
  session,
  item,
}: {
  session?: Session;
  item?: { claimantId?: string | null };
}) => !!session?.itemId && session.itemId === item?.claimantId;

export const isNotificationRecipient = ({
  session,
  item,
}: {
  session?: Session;
  item?: { recipientId?: string | null };
}) => !!session?.itemId && session.itemId === item?.recipientId;

// Filter version: restricts a query to only the current user's notifications.
// Keystone `filter` functions must return a *filter object*, not a boolean.
export const notificationsForCurrentUser = ({ session }: { session?: Session }) => {
  if (!session?.itemId) return false; // not logged in -> see nothing
  return { recipient: { id: { equals: session.itemId } } };
};