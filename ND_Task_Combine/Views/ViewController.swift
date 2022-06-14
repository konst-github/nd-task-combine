//
//  ViewController.swift
//  ND_Task_Combine
//

import UIKit
import Combine
import MessageUI

class ViewController: UIViewController {

	@IBOutlet weak var searchField: UITextField!
	@IBOutlet weak var tableView: UITableView!

	let viewModel = ViewModel()

	private var subscriptions = Set<AnyCancellable>()

	override func viewDidLoad() {
		super.viewDidLoad()

		searchField.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		tableView.keyboardDismissMode = .onDrag

		bindOwnEventsToModel()
		subscribeToEventsFromModel()
		
		viewModel.subscribe()
		viewModel.loadNews()
	}

	private func subscribeToEventsFromModel() {

		// View controller only shows the state in UI,
		// so we subscribe to any model events here
		viewModel.subjectModelEvents
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] event in
				print("ViewController model event: \(event)")
				self?.tableView.reloadData()
			})
			.store(in: &subscriptions)
	}

	private func bindOwnEventsToModel() {

		// View controller should notify view model when search text changes
		searchField.textPublisher
			.receive(on: DispatchQueue.main)
			.sink(receiveValue: { [weak self] searchText in
				self?.viewModel.searchText.value = searchText ?? ""
			})
			.store(in: &subscriptions)
	}

	fileprivate func showEmailCompose(news: NewsEntity) {
		if MFMailComposeViewController.canSendMail() {
			let composeVC = MFMailComposeViewController()
			composeVC.mailComposeDelegate = self
			composeVC.setToRecipients(["fake_email@company.dotcom"])
			composeVC.setSubject(news.title)
			composeVC.setMessageBody(news.description, isHTML: false)

			self.present(composeVC, animated: true, completion: nil)
		}
		else {
			let alert = UIAlertController.init(title: "Can't send email",
											   message: "Email sending is not set up",
											   preferredStyle: .alert)
			alert.addAction(UIAlertAction.init(title: "OK", style: .cancel))
			self.present(alert, animated: true, completion: nil)
		}
	}

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {

	// Using here an old school approach for now, as just found a CombineDataSources from CombineCommunity,
	// which allows a nice binding similar to what we have in SwiftUI, but need to sit with it for a bit
	// to handle properly :-)

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
		guard let cell = cell as? NewsCell else { return cell }
		let news = viewModel.news()
		if news.count > indexPath.row {
			cell.updateFrom(news[indexPath.row])
		}
		return cell
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.news().count
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let news = viewModel.news()
		if news.count > indexPath.row {
			showEmailCompose(news: news[indexPath.row])
		}
	}
}

extension ViewController: MFMailComposeViewControllerDelegate {
	public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true)
	}
}

extension ViewController: UITextFieldDelegate {
	// Added to be able to remove keyboard from the screen on return click
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	}
}

extension UITextField {

	var textPublisher: AnyPublisher<String?, Never> {
			NotificationCenter.default.publisher (
				for: UITextField.textDidChangeNotification,
				object: self
			)
			.map { ($0.object as? UITextField)?.text }
			.eraseToAnyPublisher()
	}
}
