//
//  NewsEntity.swift
//  ND_Task_Combine
//

import UIKit
import Combine

class NewsEntity {

	var id = 0
	var title = ""
	var description = ""
	var imageURL = ""

	var image = CurrentValueSubject<UIImage?, Never>(nil)

	var cancellable: AnyCancellable?
	
	init(id: Int, title: String, description: String, imageURL: String) {
		self.id = id
		self.title = title
		self.description = description
		self.imageURL = imageURL

		// Note = there is either error in JSON , or it is done intentionally,
		// but one of image URLs (entity with id = 14014931) doesn't have a 'preview' path component.
		// We can also handle this by using a downloadTask, not a dataTask
		// (as it looks like without 'preview' component URL points to file directly, not to the stream)
		// but just adding path component here as a simpler workaround
		if !self.imageURL.containsCaseInsensitive("/preview") {
			self.imageURL.append("/preview")
		}
	}

	func loadImage() {

		// Note: loading of images is not done inside tableview cell intentionally,
		// as it is a bad approach.

		let url = URL(string: imageURL)
		cancellable = URLSession.shared
			.dataTaskPublisher(for: url!)
			.map {
				UIImage(data: $0.data)
			}
			.replaceError(with: nil)
			.assign(to: \.image.value, on: self)
	}
}
