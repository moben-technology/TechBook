const express = require('express');
const router = express.Router();
const Sector = require('../models/sector');

//get all sectors
router.get('/getAllSectors', function (req, res) {
    try {
        Sector.find(function (err, sectors) {
            if (err) {
                res.json({
                    status: 0,
                    message: ('error get list sectors.' + err)

                });

            } else {
                res.json({
                    status: 1,
                    message: 'get list sectors successfully',
                    data: {
                        sectors: sectors,
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

// the rest of all this web services are unused in mobile app but just for managment of sectors

// add sector
router.post('/addSector', function (req, res) {
    try {
        var newSector = new Sector({
            nameSector: req.body.nameSector,
        });
        //save the sector
        newSector.save(function (err, savedSector) {
        if (err) {
            res.json({
                status: 0,
                message: err
            });
        } else {
            res.json({
                status: 1,
                message: 'Sector added successfully',
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

// update sector
router.post('/updateSector', function (req, res) {
    try {
        Sector.findOne({_id: req.body.sectorId}, function (err, sector) {
            if (err) {
                res.json({
                    status: 0,
                    message: ('Error update sector') + err
                });
            } else {
                if (!sector) {
                    res.json({
                        status: 0,
                        message: ('sector does not exist')

                    });
                } else {
                    try {
                        if (req.body.nameSector) {
                            sector.nameSector = req.body.nameSector;
                        }
                        sector.save(function (err, savedSector) {
                            if (err) {
                                res.json({
                                    status: 0,
                                    message: ('error Update sector ') + err
                                });
                            } else {
                                res.json({
                                    status: 1,
                                    message: 'Update sector successfully',
                                    data: {
                                        sector: savedSector.getSector(),
                                    }
                                })
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

// delete sector 
router.post('/deleteSector', function (req, res) {
    try {
        Sector.findOne({_id: req.body.id}, function (err, sector) {

            if (err) {
                res.json({

                    status: 0,
                    message: ('Error')

                });
            } else {
                if (!sector) {
                    res.json({

                        status: 0,
                        message: ('Sector does not exist')

                    });
                } else {

                    sector.remove(function (err, sector) {
                        if (err) {
                            res.json({
                                status: 0,
                                message: ('Error')
                            });

                        }
                        else {
                            res.json({
                                status: 1,
                                message: ('Sector deleted successfully')

                            });
                        }

                    });
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

module.exports = router;