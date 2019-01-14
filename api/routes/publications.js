const express = require('express');
const router = express.Router();
const Publication = require('../models/publication');
var multer = require('multer');
var path = require('path');
var fs = require('fs');
const mongoose = require('mongoose');

// upload file (image || video) via multer
var storageFile = multer.diskStorage({
    destination: function (req, file, cb) {
        if (path.extname(file.originalname) == ".mp4"){
            cb(null, 'Uploads/videos/')
        }else{
            cb(null, 'Uploads/images/publications/')
        }
        
    },
    filename: function (req, file, cb) {
        cb(null, Date.now() + path.extname(file.originalname)) //Appending extension
    }
});
const uploadFile = multer({storage: storageFile});

var pathFolderImagesPublications = 'Uploads/images/publications/';
var pathFolderVideosPublications = 'Uploads/videos/';

// add publication
router.post('/AddPublication',uploadFile.single('file'), function (req, res) {
    try {
        var newPublication = new Publication();
        if (req.file){
            newPublication.name_file = req.file.filename
        }
        newPublication.title = req.body.title
        newPublication.text = req.body.text
        newPublication.sector = req.body.sectorId
        newPublication.owner = req.body.userId
        newPublication.type_file = req.body.type_file
        
        //save the publication
        newPublication.save(function (err, savedPublication) {
        if (err) {
            res.json({
                status: 0,
                message: err
            });
        } else {
            res.json({
                status: 1,
                message: 'Publication added successfully',
                data: savedPublication.getPublication()
            })
        }
    });
    } catch (err) {
        res.json({
            status: 0,
            message: '500 Internal Server Error',
            data: {}
        })

    }
});

// get Publication By Id
router.post('/getPublicationById', function (req, res) {
    try {

        Publication.findOne({'_id': req.body.publicationId}).populate('owner',{'firstName': 1,'lastName':1}).populate('sector').exec(function (err, publication) {
            if (err) {
                return res.json({
                    status: 0,
                    message: ('error get Publication ' + err)
                });
            }
            if (!publication) {
                return res.json({
                    status: 0,
                    message: ('Publication does not exist')
                });
            }
             else {
                    res.json({
                        status: 1,
                        message: 'get Publication successfully',
                        data: {
                            publication: publication.getPublication(),
                        }
                    });
                }
        });
    

    } catch (err) {
        console.log(err);
        res.json({
            status: 0,
            message: '500 Internal Server Error',
            data: {}
        })

    }
});

// get Publications By Owner with pagination
router.post('/getAllPublicationsByUser', function (req, res) {
    try {
        var perPage = 10, page = 1;
        if (req.body.perPage !== undefined) {
            perPage = parseInt(req.body.perPage);
        }
        if (req.body.page !== undefined) {
            page = parseInt(req.body.page);
        }
        Publication
        .find({'owner': req.body.userId}, {}, {
            sort: {'date': -1},
            skip: (perPage * page) - perPage,
            limit: perPage})
        .populate('owner',{'firstName': 1,'lastName':1})
        .populate('sector')
        .exec(function (err, publications) {
            if (err) {
                return res.json({
                    status: 0,
                    message: ('error get Publication ' + err)
                });
            }
            else {
                // configs is now a map of JSON data
                Publication.find({'owner': req.body.userId}).exec(function (err, count) {
                    res.json({
                        status: 1,
                        message: 'get Publications By User successfully',
                        data: {
                            publications: publications,
                            currentPage: page,
                            Totalpages: Math.ceil(count.length / perPage)
                        }
                    });
                });
            }
        });
    } catch (err) {
        console.log(err);
        res.json({
            status: 0,
            message: '500 Internal Server Error',
            data: {}
        })

    }
});

// delete publication by Id
router.post('/deletePublication', function (req, res) {
    try {

        Publication.findOne({'_id': req.body.publicationId}).exec(function (err, publication) {
            if (err) {
                return res.json({
                    status: 0,
                    message: ('error get Publication ' + err)
                });
            }
            if (!publication) {
                return res.json({
                    status: 0,
                    message: ('Publication does not exist')
                });
            }
            else {
                // delete file of publication
                if (publication.name_file) {
                    var fullPath;
                    // get full path of file (video || image)
                    if (publication.type_file == "video") {
                        fullPath = pathFolderVideosPublications + publication.name_file;
                    }else{
                        fullPath = pathFolderImagesPublications + publication.name_file;
                    }
                    fs.stat(fullPath, function (err, stats) {
                        if (err) {
                            return console.error(err);
                        }
                        fs.unlink((fullPath), function (err) {
                            if (err) return console.log(err);
                        });
                    });
                }
                publication.remove(function (err, publication) {
                    if (err) {
                        return res.json({
                            status: 0,
                            message: ('error delete Publication ' + err)
                        });
                    }
                    else {
                        res.json({
                            status: 1,
                            message: 'Publication deleted successfully',
                        });
                    }
                });

            }
        });
    

    } catch (err) {
        console.log(err);
        res.json({
            status: 0,
            message: '500 Internal Server Error',
            data: {}
        })

    }
});

// add Comment to publication
router.post('/addComment', function (req, res) {
    try {
        Publication.findOne({'_id': req.body.publicationId}).exec(function (err, publication) {
            if (err) {
                return res.json({
                    status: 0,
                    message: ('Error find publication ') + err
                });
            } else {
                try {
                    var commentContent = [];
                    if (req.body.text) {
                        commentContent = publication.comments;
                        const comment = {
                            text: req.body.text,
                            author: req.body.userId,
                        };
                        commentContent.push(comment);
                        publication.comments = commentContent;
                        publication.save(function (err) {
                            if (err) {
                                console.log('error' + err)
                            } else {
                                return res.json({
                                    status: 1,
                                    message: 'Comment added succeffully '
                                });
                            }
                        });
                    }
                } catch (err) {
                    console.log(err);
                    res.json({
                        status: 0,
                        message: '500 Internal Server Error',
                        data: {}
                    })

                }
            }
        });

    } catch (err) {
        console.log(err);
        res.json({
            status: 0,
            message: '500 Internal Server Error',
            data: {}
        })

    }
});

// get all comments of publication with pagination
router.post('/getCommentsByPublication', function (req, res) {
    try {
        var perPage = 10, page = 1;
        if (req.body.perPage !== undefined) {
            perPage = parseInt(req.body.perPage);
        }
        if (req.body.page !== undefined) {
            page = parseInt(req.body.page);
        }
        var option = {"_id": mongoose.Types.ObjectId(req.body.publicationId)}
        Publication.aggregate([
            {"$unwind": "$comments"},
            {"$match": option},
            {"$sort": {"_id": 1, "comments.date": -1}},
            {"$skip": (perPage * page) - perPage}, {"$limit": perPage},
            {"$group": {"_id": "$_id", "comments": {"$push": "$comments"}}}

        ]).exec(function (err, comment) {
            if (err) {
                res.json({
                    status: 0,
                    message: ('erreur get all Comment ') + err
                });
            } else {
                try {
                    Publication.findOne({_id: req.body.publicationId}).exec(function (err, count) {
                        if (err) {
                            res.json({
                                status: 0,
                                message: ('erreur get count publication ') + err
                            });
                        } else {
                            try {
                                Publication.populate(comment, {
                                    path: 'comments.author',
                                    select: '_id firstName lastName pictureProfile'
                                }, function (err, populatedComment) {
                                    // Your populated translactions are inside populatedTransactions

                                    var commentsList = [];
                                    if (populatedComment.length > 0) {
                                        commentsList = populatedComment[0].comments;
                                    }
                                    if (count) {
                                        if (count.comments) {
                                            var countComments;
                                            countComments = count.comments;
                                            res.json({
                                                status: 1,
                                                message: 'get Comment  All succeffully',
                                                data: {
                                                    comments: commentsList,
                                                    currentPage: page,
                                                    totalPages: Math.ceil(countComments.length / perPage)
                                                }
                                            });
                                        }
                                    } else {
                                        res.json({
                                            status: 1,
                                            message: 'get Comment  All succeffully',
                                            data: {
                                                comments: commentsList,
                                                current: page,
                                                pages: 1
                                            }
                                        });
                                    }
                                });
                            } catch (err) {
                                console.log(err);
                                res.json({
                                    status: 0,
                                    message: '500 Internal Server Error',
                                    data: {}
                                })

                            }
                        }
                    });
                } catch (err) {
                    console.log(err);
                    res.json({
                        status: 0,
                        message: '500 Internal Server Error',
                        data: {}
                    })

                }
            }
        });
    } catch (err) {
        console.log(err);
        res.json({
            status: 0,
            message: '500 Internal Server Error',
            data: {}
        })

    }
});

// delete comment 
router.post('/deleteComment', function (req, res) {
    Publication.findOne({'_id':req.body.publicationId},function (err,publication) {
        if (err) {
            return res.json({
                status: 0,
                message: ('Error find publication ') + err
            });
        } else {
            for (var i = 0; i < publication.comments.length; i++) {
                if(publication.comments[i]._id==req.body.commentId)
                {
                    publication.comments.splice(i,1);
                }
            }
            publication.save();
            res.json({
                status: 1,
                message : 'comment succefuuly deleted'
            });
        }
    });
});



module.exports = router;