const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const config = require('../config');
const Comment = require('./comment').commentSchema;
const Like = require('./like').likeSchema;
var pathFolderImagesPublications = 'uploads/images/publications/';
var pathFolderVideosPublications = 'uploads/videos/';

const publicationSchema = new Schema({
    title: {
        type: String,      
    },
    text: {
        type: String,      
    },
    type_file: {
        type: String,  // image || video
    },
    name_file: {
        type: String,      
    },
    sector: {
        type: Schema.ObjectId,
        ref: 'Sector'
    },
    owner: {
        type: Schema.ObjectId,
        ref: 'User'
    },
    createdAt:Date,
    comments: [Comment],
    likes: [Like],
    },
    {
        toJSON:{virtuals:true}
    });

publicationSchema.virtual('url_file').get(function () {
    if (this.type_file == "image") {
    return config.host+pathFolderImagesPublications + this.name_file;
    }else if (this.type_file == "video"){
        return config.host+pathFolderVideosPublications + this.name_file;
    }
});

publicationSchema.methods.getPublication=function () {

    return({
        _id: this._id,
        title: this.title,
        text: this.text,
        type_file: this.type_file,
        name_file: this.name_file,
        url_file: this.url_file,
        sector: this.sector,
        owner: this.owner,
        nbrComments: this.comments.length,
        nbrLikes: this.likes.length,
        isLiked: false,
        createdAt: this.createdAt,
    })
};

publicationSchema.methods.getPublicationDetails=function () {
    return({
        _id: this._id,
        title: this.title,
        text: this.text,
        type_file: this.type_file,
        name_file: this.name_file,
        url_file: this.url_file,
        sector: this.sector,
        owner: this.owner,
        createdAt: this.createdAt,
    })
};

var publicationModel = mongoose.model('Publication', publicationSchema);
module.exports = {
    publicationModel : publicationModel,
    publicationSchema : publicationSchema
};