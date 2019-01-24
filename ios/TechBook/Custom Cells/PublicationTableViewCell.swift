//
//  PublicationTableViewCell.swift
//  TechBook
//
//  Created by MacBook on 22/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit
import SDWebImage

protocol PublicationTableViewCellDelegate : class {
    func didBtnLikeClicked(publication: Publication, cell: UITableViewCell, indexPathCell : IndexPath, tableView: UITableView)
    func didBtnGetCommentsClicked(_id: String, cell: UITableViewCell, indexPathCell : IndexPath, tableView: UITableView)
    func didLabelNameOwnerPubTapped(idOwnerPub: String, cell: UITableViewCell, indexPathCell : IndexPath, tableView: UITableView)
    func didLabelNameSectorTapped(sector: Sector, cell: UITableViewCell, indexPathCell : IndexPath, tableView: UITableView)
    func didLabelNbrLikesTapped(idPublication: String,nbrLikes: Int, cell: UITableViewCell, indexPathCell : IndexPath, tableView: UITableView)
}

class PublicationTableViewCell: UITableViewCell {

    @IBOutlet weak var imageProfileOwnerPub: UIImageView!
    @IBOutlet weak var nameOwnerPubLabel: UILabel!
    @IBOutlet weak var dateAddPubLabel: UILabel!
    @IBOutlet weak var titlePubLabel: UILabel!
    @IBOutlet weak var nameSectorLabel: UILabel!
    @IBOutlet weak var textPubLabel: UILabel!
    @IBOutlet weak var imagePub: UIImageView!
    @IBOutlet weak var videoPub: UIWebView!
    @IBOutlet weak var nbrLikesLabel: UILabel!
    @IBOutlet weak var nbrCommentsLabel: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    
    var publication : Publication?
    var tableView: UITableView?
    var indexPathCell : IndexPath?
    var delegatePublication : PublicationTableViewCellDelegate?
    
    public func loadData(publication : Publication, indexPathCell : IndexPath, tableView: UITableView) {
        // setup Cell
        self.publication = publication
        self.indexPathCell = indexPathCell
        self.tableView = tableView
        // setup data
        self.nameOwnerPubLabel.text = publication.owner.firstName! + " " + publication.owner.lastName!
        self.imageProfileOwnerPub.sd_setImage(with: URL(string: publication.owner.pictureProfile!))
        self.imageProfileOwnerPub.layer.cornerRadius = self.imageProfileOwnerPub.frame.size.width/2
        self.imageProfileOwnerPub.clipsToBounds = true
        // setup pub details
        self.dateAddPubLabel.text = publication.createdAt
        self.titlePubLabel.text = publication.title
        self.nameSectorLabel.text = publication.sector.nameSector
        self.textPubLabel.text = publication.text
        if ((publication.type_file ) != nil){
            if(publication.type_file == "image"){
                self.videoPub.isHidden = true
                self.imagePub.isHidden = false
                self.imagePub.sd_setImage(with: URL(string: publication.url_file!))
            }else if (publication.type_file == "video"){
                self.imagePub.isHidden = true
                self.videoPub.isHidden = false
                
                DispatchQueue.main.async {
                    self.videoPub.loadHTMLString("<iframe width= \" \(self.videoPub.frame.width) \"height=\"\(self.videoPub.frame.height)\"src = \"\(publication.url_file!)\"> </iframe>", baseURL: nil)
                }
                videoPub.scrollView.isScrollEnabled = false
                videoPub.scrollView.bounces = false
                
            }
            
        }else{
            self.imagePub.isHidden = true
            self.videoPub.isHidden = true
        }
        if(publication.isLiked == true) {
            self.btnLike.setImage(UIImage(named: "ic_favorite_red"), for: .normal)
        }else{
            self.btnLike.setImage(UIImage(named: "ic_favorite_border_black"), for: .normal)
        }
        self.nbrLikesLabel.text =  "\(publication.nbrLikes!) " + "Likes"
        self.nbrCommentsLabel.text =  "\(publication.nbrComments!) " + "Comments"
        
        let tapNameOwnerLabel = UITapGestureRecognizer(target: self, action: #selector(PublicationTableViewCell.showProfileOwnerPub))
        nameOwnerPubLabel.isUserInteractionEnabled = true
        nameOwnerPubLabel.addGestureRecognizer(tapNameOwnerLabel)
        
        let tapNameSectorLabel = UITapGestureRecognizer(target: self, action: #selector(PublicationTableViewCell.showAllPubBySector))
        nameSectorLabel.isUserInteractionEnabled = true
        nameSectorLabel.addGestureRecognizer(tapNameSectorLabel)
        
        let tapNbrLikesLabel = UITapGestureRecognizer(target: self, action: #selector(PublicationTableViewCell.showAllLikes))
        nbrLikesLabel.isUserInteractionEnabled = true
        nbrLikesLabel.addGestureRecognizer(tapNbrLikesLabel)
        

        
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnLikeAction(_ sender: Any) {
        delegatePublication?.didBtnLikeClicked(publication: (self.publication)!, cell: self, indexPathCell: self.indexPathCell!, tableView: self.tableView!)
    }
    
    @IBAction func btnShowComments(_ sender: Any) {
        delegatePublication?.didBtnGetCommentsClicked(_id: (self.publication?._id)!, cell: self, indexPathCell: self.indexPathCell!, tableView: self.tableView!)
    }
    
    @objc func showProfileOwnerPub() {
        delegatePublication?.didLabelNameOwnerPubTapped(idOwnerPub: (self.publication?.owner._id)!, cell: self, indexPathCell: self.indexPathCell!, tableView: self.tableView!)
    }
    
    @objc func showAllPubBySector() {
        delegatePublication?.didLabelNameSectorTapped(sector: (self.publication?.sector)!, cell: self, indexPathCell: self.indexPathCell!, tableView: self.tableView!)
    }
    
    @objc func showAllLikes() {
        delegatePublication?.didLabelNbrLikesTapped(idPublication: (self.publication?._id)!,nbrLikes: (self.publication?.nbrLikes)!, cell: self, indexPathCell: self.indexPathCell!, tableView: self.tableView!)
    }
    
}
