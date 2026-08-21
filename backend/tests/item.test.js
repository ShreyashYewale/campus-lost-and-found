const test = require('node:test');
const assert = require('node:assert/strict');
const { createUserAndAuthenticate, createItem, fetchGraphQL } = require('./helpers');

test('Create a lost item via GraphQL when authenticated', async () => {
  const { userId, sessionToken } = await createUserAndAuthenticate('Item Poster', 'item_poster');

  const { response, body } = await createItem(sessionToken, {
    title: 'Lost Blue Water Bottle',
    description: 'Blue Hydro Flask left in Library on the second floor',
    type: 'lost',
    category: 'electronics',
    location: 'library',
    status: 'open',
    postedBy: { connect: { id: userId } },
  });

  assert.equal(response.status, 200);
  assert.ok(body.data?.createItem?.id, 'Expected item id to be returned');
  assert.equal(body.data.createItem.title, 'Lost Blue Water Bottle');
  assert.equal(body.data.createItem.type, 'lost');
  assert.equal(body.data.createItem.category, 'electronics');
  assert.equal(body.data.createItem.location, 'library');
  assert.equal(body.data.createItem.status, 'open');
});

test('Creating a matching item generates notifications for both users', async () => {
  const lostUser = await createUserAndAuthenticate('Lost Owner', 'lost_owner');
  const foundUser = await createUserAndAuthenticate('Found Owner', 'found_owner');

  await createItem(lostUser.sessionToken, {
    title: 'Lost Student ID',
    description: 'ID card lost near library',
    type: 'lost',
    category: 'id_cards',
    location: 'library',
    status: 'open',
    postedBy: { connect: { id: lostUser.userId } },
  });

  await createItem(foundUser.sessionToken, {
    title: 'Found Student ID',
    description: 'ID card found near library',
    type: 'found',
    category: 'id_cards',
    location: 'library',
    status: 'open',
    postedBy: { connect: { id: foundUser.userId } },
  });

  const notificationsQuery = `
    query GetNotifications {
      notifications {
        id
        type
        message
        recipient { id }
      }
    }
  `;

  const lostNotifications = await fetchGraphQL(notificationsQuery, {}, lostUser.sessionToken);
  const foundNotifications = await fetchGraphQL(notificationsQuery, {}, foundUser.sessionToken);

  const lostMatches = (lostNotifications.body.data?.notifications ?? []).filter(
    (notification) => notification.type === 'match'
  );
  const foundMatches = (foundNotifications.body.data?.notifications ?? []).filter(
    (notification) => notification.type === 'match'
  );

  assert.ok(lostMatches.length >= 1, 'Lost item owner should receive a match notification');
  assert.ok(foundMatches.length >= 1, 'Found item owner should receive a match notification');
});
