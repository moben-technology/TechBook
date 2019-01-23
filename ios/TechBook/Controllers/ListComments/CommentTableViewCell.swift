//
//  CommentTableViewCell.swift
//  TechBook
//
//  Created by MacBook on 23/01/2019.
//  Copyright © 2019 MacBook. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate : class {
    func didBtnDeleteCommentClicked(comment: Comment, cell: UITableViewCell, indexPathCell : IndexPath, tableView: UITableView)
}

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var imageProfileAuthor: UIImageView!
    @IBOutlet weak var nameAuthor: UILabel!
    @IBOutlet weak var textComment: UILabel!
    @IBOutlet weak var dateComment: UILabel!
    @IBOutlet weak var btnDeleteComment: UIButton!
    
    var delegateComment: CommentTableViewCellDelegate?
    var comment : Comment?
    var tableView: UITableView?
    var indexPathCell : IndexPath?
    
    public func loadData(comment : Comment, indexPathCell : IndexPath, tableView: UITableView) {
        // setup Cell
        self.comment = comment
        self.indexPathCell = indexPathCell
        self.tableView = tableView
        // setup author data
        self.nameAuthor.text = comment.author.firstName! + " " + comment.author.lastName!
        self.imageProfileAuthor.sd_setImage(with: URL(string: comment.author.pictureProfile!))
        self.imageProfileAuthor.layer.cornerRadius = self.imageProfileAuthor.frame.size.width/2
        self.imageProfileAuthor.clipsToBounds = true
        // setup author data
        self.textComment.text = comment.text
        self.dateComment.text = comment.date
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnDeleteCommentAction(_ sender: Any) {
        delegateComment?.didBtnDeleteCommentClicked(comment: (self.comment)!, cell: self, indexPathCell: self.indexPathCell!, tableView: self.tableView!)
    }
    

}
