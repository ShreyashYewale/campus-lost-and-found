import { type KeystoneContext } from '@keystone-6/core/types';
 
// Normalises a title so small differences (case, spacing, punctuation)
// don't stop us catching an obvious duplicate.
function normalise(text: string): string {
  return text
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}
 
// Very small similarity check: how many words the two titles share.
// Returns a value between 0 and 1.
function titleSimilarity(a: string, b: string): number {
  const wordsA = normalise(a).split(' ').filter(Boolean);
  const wordsB = normalise(b).split(' ').filter(Boolean);
  if (wordsA.length === 0 || wordsB.length === 0) return 0;
 
  const setB = new Set(wordsB);
  const shared = wordsA.filter((w) => setB.has(w)).length;
  return shared / Math.max(wordsA.length, wordsB.length);
}
 
export type PossibleDuplicate = {
  id: string;
  title: string;
  createdAt?: string;
};
 
// Looks for an existing item by the same user that looks like the same thing:
// same type + category + location, and a similar title.
export async function findPossibleDuplicate(
  context: KeystoneContext,
  data: {
    title: string;
    type: string;
    category: string;
    location: string;
    postedById?: string | null;
  }
): Promise<PossibleDuplicate | null> {
  if (!data.postedById) return null;
 
  const sudo = context.sudo();
 
  // Only compare against this user's own recent open items of the same
  // type/category/location - that's where an accidental double-post happens.
  const candidates = await sudo.db.Item.findMany({
    where: {
      AND: [
        { postedBy: { id: { equals: String(data.postedById) } } },
        { type: { equals: data.type } },
        { category: { equals: data.category } },
        { location: { equals: data.location } },
        { status: { equals: 'open' } },
      ],
    },
  });
 
  for (const candidate of candidates) {
    const similarity = titleSimilarity(data.title, candidate.title as string);
    if (similarity >= 0.6) {
      return {
        id: String(candidate.id),
        title: candidate.title as string,
        createdAt: candidate.createdAt ? String(candidate.createdAt) : undefined,
      };
    }
  }
 
  return null;
}