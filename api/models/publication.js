const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const config = require('../config');
const Comment = require('./comment').commentSchema;
var pathFolderImagesPublications = 'Uploads/images/publications/';
var pathFolderVideosPublications = 'Uploads/videos/';

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
    createdAt: {
        type: Date,
        default: Date.now()
    },
    comments: [Comment],
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
        createdAt: this.createdAt,
    })
};

publicationSchema.methods.getPublicationDetails=function () {
    var  owner;
    if (  this.owner !== undefined && this.owner !== null){
        if(this.owner._id) {
            //owner = this.owner.Schema;
            //owner = "hh";
        }else{
            owner = this.owner;
        }
    }else{
        owner = this.owner
    }
    return({
        _id: this._id,
        title: this.title,
        text: this.text,
        type_file: this.type_file,
        name_file: this.name_file,
        url_file: this.url_file,
        sector: this.sector,
        owner: owner,
        createdAt: this.createdAt,
    })
};


const Publication = module.exports = mongoose.model('Publication', publicationSchema);