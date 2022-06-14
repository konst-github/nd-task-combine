//
//  DataLoaderCombine.swift
//  ND_Task
//
//  Created by Konstantin on 14/06/2022.
//

import Combine
import UIKit


class DataLoaderCombine {

	private struct NewsData: Codable {
		let id: Int
		let title: String
		let description: String
		let imageUrl: String
	}

	func load() -> AnyPublisher<[NewsEntity], Error> {

		let urlString = "https://cloud.nousdigital.net/s/rNPWPNWKwK7kZcS/download"
		let url = URL(string: urlString)

		return URLSession.shared.dataTaskPublisher(for: url!)
			.tryMap({ (data, response) -> Data in
				if let response = response as? HTTPURLResponse {
				   print(response.statusCode)
				}
				return data
			})
			.decode(type: [String:[NewsData]].self, decoder: JSONDecoder())
			.compactMap { dict -> [NewsEntity] in
				guard let array = dict["items"]
				else { return [NewsEntity]() }

				// Map primitive NewsData entities into NewsEntity class,
				// which will also handle image download
				return array.map {
					NewsEntity(id: $0.id, title: $0.title, description: $0.description, imageURL: $0.imageUrl)
				}
			}
			.eraseToAnyPublisher()
	}
}
