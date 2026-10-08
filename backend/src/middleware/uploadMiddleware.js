const multer = require('multer');

const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = [
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'text/plain',
  ];

  if (allowedMimeTypes.includes(file.mimetype) || file.originalname.toLowerCase().endsWith('.pdf')) {
    cb(null, true);
  } else {
    cb(new Error('Invalid file format. Only PDF and document files are allowed.'), false);
  }
};

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 15 * 1024 * 1024, // 15MB file size limit
  },
});

module.exports = upload;
