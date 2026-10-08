const https = require('https');
const http = require('http');
const cloudinary = require('../config/cloudinary');

// @desc    Upload PDF/Document file to Cloudinary
// @route   POST /api/upload
// @access  Private (College Admin / Super Admin)
const uploadFile = async (req, res) => {
  try {
    // Check if Cloudinary credentials are configured
    const isCloudinaryConfigured =
      process.env.CLOUDINARY_CLOUD_NAME &&
      process.env.CLOUDINARY_API_KEY &&
      process.env.CLOUDINARY_API_SECRET &&
      !process.env.CLOUDINARY_CLOUD_NAME.includes('your_cloudinary');

    if (!isCloudinaryConfigured) {
      return res.status(503).json({
        success: false,
        isConfigured: false,
        message:
          'Cloudinary storage credentials not configured in backend/.env. Please set CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET.',
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please select a valid PDF/Document file to upload',
      });
    }

    // Stream upload buffer to Cloudinary
    const uploadStream = (fileBuffer) => {
      return new Promise((resolve, reject) => {
        const stream = cloudinary.uploader.upload_stream(
          {
            folder: 'svpuat_documents',
            resource_type: 'auto',
          },
          (error, result) => {
            if (result) {
              resolve(result);
            } else {
              reject(error);
            }
          }
        );
        stream.end(fileBuffer);
      });
    };

    const result = await uploadStream(req.file.buffer);

    return res.status(200).json({
      success: true,
      message: 'File uploaded successfully to Cloudinary',
      fileUrl: result.secure_url,
      publicId: result.public_id,
      fileName: req.file.originalname,
      fileSize: `${(req.file.size / (1024 * 1024)).toFixed(2)} MB`,
    });
  } catch (error) {
    console.error('Cloudinary Upload Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error uploading file to Cloudinary',
    });
  }
};

// @desc    Delete PDF/Document file from Cloudinary
// @route   DELETE /api/upload
// @access  Private (College Admin / Super Admin)
const deleteFile = async (req, res) => {
  try {
    const { publicId } = req.body;
    if (!publicId) {
      return res.status(400).json({
        success: false,
        message: 'Public ID is required to delete file from Cloudinary',
      });
    }

    const result = await cloudinary.uploader.destroy(publicId, {
      resource_type: 'raw',
    });

    return res.status(200).json({
      success: true,
      message: 'File removed from Cloudinary storage',
      result,
    });
  } catch (error) {
    console.error('Cloudinary Delete Error:', error);
    return res.status(500).json({
      success: false,
      message: error.message || 'Error deleting file from Cloudinary',
    });
  }
};

// @desc    Secure JWT Proxy for In-App Streamed PDF Viewing
// @route   GET /api/upload/stream-pdf
// @access  Private (Authenticated Students / Admins)
const streamPdfProxy = async (req, res) => {
  try {
    const targetUrl = req.query.url;
    if (!targetUrl) {
      return res.status(400).json({
        success: false,
        message: 'PDF URL query parameter is required',
      });
    }

    const client = targetUrl.startsWith('https') ? https : http;

    client
      .get(targetUrl, (cloudinaryRes) => {
        if (cloudinaryRes.statusCode >= 400) {
          return res.status(cloudinaryRes.statusCode).json({
            success: false,
            message: 'Error fetching PDF stream from Cloudinary',
          });
        }

        res.setHeader('Content-Type', 'application/pdf');
        res.setHeader('Content-Disposition', 'inline');
        cloudinaryRes.pipe(res);
      })
      .on('error', (err) => {
        res.status(500).json({
          success: false,
          message: err.message || 'Error streaming PDF from Cloudinary',
        });
      });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message || 'Server error proxying PDF stream',
    });
  }
};

module.exports = {
  uploadFile,
  deleteFile,
  streamPdfProxy,
};
