const assert = require('node:assert/strict');

async function fetchGraphQL(query, variables = {}, sessionToken = null) {
  const headers = { 'Content-Type': 'application/json' };
  if (sessionToken) {
    headers.Authorization = `Bearer ${sessionToken}`;
  }

  const response = await fetch('http://localhost:3000/api/graphql', {
    method: 'POST',
    headers,
    body: JSON.stringify({ query, variables }),
  });

  const body = await response.json();
  return { response, body };
}

async function createUserAndAuthenticate(name, emailPrefix, password = 'testpass123') {
  const email = `${emailPrefix}_${Date.now()}@campus.test`;

  const createUser = `
    mutation CreateUser($name: String!, $email: String!, $password: String!) {
      createUser(data: { name: $name, email: $email, password: $password }) {
        id
        name
        email
      }
    }
  `;

  const createResult = await fetchGraphQL(createUser, { name, email, password });
  assert.ok(createResult.body.data?.createUser?.id, 'Expected user to be created');

  const authenticate = `
    mutation AuthenticateUserWithPassword($email: String!, $password: String!) {
      authenticateUserWithPassword(email: $email, password: $password) {
        ... on UserAuthenticationWithPasswordSuccess {
          sessionToken
          item { id }
        }
      }
    }
  `;

  const authResult = await fetchGraphQL(authenticate, { email, password });
  const sessionToken = authResult.body.data?.authenticateUserWithPassword?.sessionToken;
  assert.ok(sessionToken, 'Expected session token after authentication');

  return {
    email,
    password,
    userId: createResult.body.data.createUser.id,
    sessionToken,
  };
}

async function createItem(sessionToken, itemData) {
  const createItem = `
    mutation CreateItem(
      $title: String!,
      $description: String!,
      $type: String!,
      $category: String!,
      $location: String!,
      $status: String!,
      $postedBy: UserRelateToOneForCreateInput!
    ) {
      createItem(data: {
        title: $title,
        description: $description,
        type: $type,
        category: $category,
        location: $location,
        status: $status,
        postedBy: $postedBy
      }) {
        id
        title
        type
        category
        location
        status
      }
    }
  `;

  return fetchGraphQL(createItem, itemData, sessionToken);
}

module.exports = {
  fetchGraphQL,
  createUserAndAuthenticate,
  createItem,
};
