//
//  NewsCell.swift
//  ND_Task
//
//  Created by Konstantin on 08/06/2022.
//

import UIKit

public class NewsCell: UITableViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var viewImage: UIImageView!
	@IBOutlet weak var descriptionLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!

	func updateFrom(_ newsData: NewsEntity) {
		titleLabel.text = newsData.title
		viewImage.image = newsData.image.value
		descriptionLabel.text = newsData.description
		if viewImage.image != nil { activityIndicator.stopAnimating() }
	}
}

class NewsCellBackground: UIView {
	override public var bounds: CGRect {
		didSet {
			self.layer.backgroundColor = UIColor(named: "CellBackground")?.cgColor
			self.layer.cornerRadius = 10
		}
	}
}
