jest.mock('../src/db', () => ({
  query: jest.fn(),
  pool: { end: jest.fn() },
}));

const request = require('supertest');
const db = require('../src/db');
const app = require('../src/index');

describe('Health Check', () => {
  it('should return ok status', async () => {
    const res = await request(app).get('/health');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });
});

describe('Auth', () => {
  it('should reject login without credentials', async () => {
    const res = await request(app).post('/api/auth/login').send({});
    expect(res.status).toBe(400);
  });

  it('should reject invalid credentials', async () => {
    db.query.mockResolvedValueOnce({ rows: [] });

    const res = await request(app)
      .post('/api/auth/login')
      .send({ username: 'invalid', password: 'wrong' });
    expect(res.status).toBe(401);
    expect(res.body.error).toBe('Invalid credentials');
  });
});

describe('Protected Routes', () => {
  it('should reject unauthenticated requests', async () => {
    const res = await request(app).get('/api/dashboard/counts');
    expect(res.status).toBe(401);
  });
});
