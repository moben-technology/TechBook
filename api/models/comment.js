const mongoose = require('mongoose');
const Schema = mongoose.Schema;
 
const commentSchema = new Schema ({
    text : {
        type : String,
    },
    date : {
        type: Date,
        default: Date.now()
    },
    author : {
        type: Schema.ObjectId,
        ref: 'User'
    },
});

commentSchema.methods.getComments=function () {
    var  userId;
    if ( this.userId !== undefined && this.userId !== null){
        if(this.userId._id) {
            userId = this.userId.getShortInfoUser();
        }else{
            userId = this.userId;
        }
    }else{
        userId = this.userId
    }
    return({
        _id: this._id,
        text: this.text,
        date: this.date,
        author: userId

    })
};

var commentModel = mongoose.model('Comment', commentSchema);
module.exports = {
    commentModel : commentModel,
    commentSchema : commentSchema
};