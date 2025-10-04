const multer = require('multer');
const path = require('path');
const { supabaseAdmin } = require('../config/supabase');

const storage = multer.memoryStorage();

const fileFilter = (req, file, cb) => {
    const allowedExtensions = /\.(jpeg|jpg|png|gif|webp)$/i;
    const extname = allowedExtensions.test(file.originalname.toLowerCase());
    
    const allowedMimeTypes = /^(image\/(jpeg|jpg|png|gif|webp)|application\/octet-stream)$/i;
    const mimetype = allowedMimeTypes.test(file.mimetype.toLowerCase());

    if (extname && (mimetype || file.mimetype === 'application/octet-stream')) {
        return cb(null, true);
    } else {
        cb(new Error(`Only image files are allowed (jpeg, jpg, png, gif, webp). Received: ${file.mimetype} with filename: ${file.originalname}`));
    }
};

const upload = multer({
    storage: storage,
    limits: {
        fileSize: 5 * 1024 * 1024
    },
    fileFilter: fileFilter
});

const uploadToSupabase = async (file, folder = 'posts') => {
    try {
        const fileExt = path.extname(file.originalname).toLowerCase();
        const fileName = `${Date.now()}-${Math.random().toString(36).substring(7)}${fileExt}`;
        const filePath = `${folder}/${fileName}`;

        let contentType = file.mimetype;
        if (file.mimetype === 'application/octet-stream' || !file.mimetype.startsWith('image/')) {
            const mimeTypes = {
                '.jpg': 'image/jpeg',
                '.jpeg': 'image/jpeg',
                '.png': 'image/png',
                '.gif': 'image/gif',
                '.webp': 'image/webp'
            };
            contentType = mimeTypes[fileExt] || 'image/jpeg';
        }

        const { data, error } = await supabaseAdmin.storage
            .from('images')
            .upload(filePath, file.buffer, {
                contentType: contentType,
                cacheControl: '3600',
                upsert: false
            });

        if (error) {
            throw error;
        }

        const { data: { publicUrl } } = supabaseAdmin.storage
            .from('images')
            .getPublicUrl(filePath);

        return publicUrl;
    } catch (error) {
        console.error('Supabase upload error:', error);
        throw new Error('Failed to upload image to storage');
    }
};

const deleteFromSupabase = async (imageUrl) => {
    try {
        if (!imageUrl) return;

        const urlParts = imageUrl.split('/images/');
        if (urlParts.length < 2) return;

        const filePath = urlParts[1];

        const { error } = await supabaseAdmin.storage
            .from('images')
            .remove([filePath]);

        if (error) {
            console.error('Error deleting image:', error);
        }
    } catch (error) {
        console.error('Delete from Supabase error:', error);
    }
};

module.exports = {
    upload,
    uploadToSupabase,
    deleteFromSupabase
};
