const test = require('node:test');
const assert = require('node:assert/strict');

async function fetchGraphQL(query, variables = {}) {
  const response = await fetch('http://localhost:3000/api/graphql', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query, variables }),
  });

  const body = await response.json();
  return { response, body };
}

test('Create a lost item via GraphQL', async () => {
  const createItem = `
    mutation CreateItem(
      $title: String!,
      $description: String!,
      $type: String!,
      $category: String!,
      $location: String!,
      $status: String!
    ) {
      createItem(data: {
        title: $title,
        description: $description,
        type: $type,
        category: $category,
        location: $location,
        status: $status
      }) {
        id
        title
        description
        type
        category
        location
        status
      }
    }
  `;

  const { response, body } = await fetchGraphQL(createItem, {
    title: 'Lost Blue Water Bottle',
    description: 'Blue Hydro Flask left in Library on the second floor',
    type: 'lost',
    category: 'electronics',
    location: 'library',
    status: 'open',
  });

  assert.equal(response.status, 200);
  assert.ok(body.data?.createItem?.id, 'Expected item id to be returned');
  assert.equal(body.data.createItem.title, 'Lost Blue Water Bottle');
  assert.equal(body.data.createItem.type, 'lost');
  assert.equal(body.data.createItem.category, 'electronics');
  assert.equal(body.data.createItem.location, 'library');
  assert.equal(body.data.createItem.status, 'open');
});
