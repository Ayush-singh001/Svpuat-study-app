const dns = require('dns');
if (dns.setDefaultResultOrder) {
  dns.setDefaultResultOrder('ipv4first');
}

const dotenv = require('dotenv');
const path = require('path');

// Load environment variables from backend/.env
dotenv.config({ path: path.join(__dirname, '../.env') });

const app = require('./app');
const connectDB = require('./config/database');

const PORT = process.env.PORT || 5000;

// Connect to MongoDB Atlas first, then start server listening
connectDB()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Server DB Connection Warning:', err.message);
    app.listen(PORT, () => {
      console.log(`Server running in fallback mode on port ${PORT}`);
    });
  });
