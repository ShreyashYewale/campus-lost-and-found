const test = require('node:test');
const assert = require('node:assert/strict');
const { fetchGraphQL, createUserAndAuthenticate, createItem } = require('./helpers');

test('GraphQL endpoint is available', async () => {
  const { response, body } = await fetchGraphQL('query { __typename }');

  assert.equal(response.status, 200);
  assert.equal(body.data.__typename, 'Query');
});

test('The backend exposes the User list and accepts a create mutation', async () => {
  const createUser = `
    mutation CreateUser($name: String!, $email: String!, $password: String!) {
      createUser(data: { name: $name, email: $email, password: $password }) {
        id
        name
        email
      }
    }
  `;

  const email = `user_${Date.now()}@campus.test`;
  const { response, body } = await fetchGraphQL(createUser, {
    name: 'Test User',
    email,
    password: 'testpass123',
  });

  assert.equal(response.status, 200);
  assert.ok(body.data?.createUser?.id);
  assert.equal(body.data.createUser.name, 'Test User');
  assert.equal(body.data.createUser.email, email);
});

test('Authenticated users receive a session token', async () => {
  const { sessionToken } = await createUserAndAuthenticate('Auth User', 'auth_user');
  assert.ok(sessionToken);
});
