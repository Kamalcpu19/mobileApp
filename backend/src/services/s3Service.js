const config = require('../config');

async function uploadFile(file, folder = 'uploads') {
  if (!config.aws.accessKeyId) {
    const mockUrl = `https://${config.aws.bucket}.s3.${config.aws.region}.amazonaws.com/${folder}/${Date.now()}-${file.originalname}`;
    return mockUrl;
  }

  // Production: integrate AWS SDK S3 upload
  const mockUrl = `https://${config.aws.bucket}.s3.${config.aws.region}.amazonaws.com/${folder}/${Date.now()}-${file.originalname}`;
  return mockUrl;
}

module.exports = { uploadFile };
