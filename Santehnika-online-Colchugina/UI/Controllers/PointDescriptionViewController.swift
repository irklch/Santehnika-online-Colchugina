//
//  PointDescriptionViewController.swift
//  Santehnika-online-Colchugina
//
//  Created by Ирина Кольчугина on 16.10.2021.
//

import UIKit
import YandexMapsMobile

final class PointDescriptionViewController: UIViewController {

    //MARK: - Private properties
    private let addressTextView = UITextView()
    private let addressLabel = UILabel()
    private let latitudeTextView = UITextView()
    private let latitudeLabel = UILabel()
    private let longitudeTextView = UITextView()
    private let longitudeLabel = UILabel()
    private let cancelButton = UIButton()
    private let dropDownTableView = UITableView()
    private let dropDownView = UIView()
    private var suggestResults: [YMKSuggestItem] = []
    private let searchManager = YMKSearch.sharedInstance().createSearchManager(with: .combined)
    private var suggestSession: YMKSearchSuggestSession!
    private var point = Point()
    private let boundingBox = YMKBoundingBox(
        southWest: YMKPoint(latitude: 55.55, longitude: 37.42),
        northEast: YMKPoint(latitude: 55.95, longitude: 37.82))
    private let suggestOptions = YMKSuggestOptions()
    
    //MARK: - Life cycle
    init(point: Point) {
        super.init(nibName: nil, bundle: nil)
        self.addressTextView.text = point.address
        self.latitudeTextView.text = "\(point.latitude)"
        self.longitudeTextView.text = "\(point.longitude)"
        self.point = point
    }
    
    @available (*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
        createSuggestSession()
        delegateAddressTextView()
        setTableView()
    }
    
    //MARK: - Private mathods

    //Настроить отображение полей
    private func setViews() {
        view.backgroundColor = .white
        title = "Описание"
        
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(addressLabel)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: safeArea.topAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20)
        ])
        addressLabel.backgroundColor = .white
        addressLabel.textColor = .systemGray
        addressLabel.font = addressLabel.font.withSize(12)
        addressLabel.text = "Адрес"
        
        view.addSubview(addressTextView)
        addressTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addressTextView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 5),
            addressTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            addressTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20)
        ])
        addressTextView.layer.cornerRadius = 5
        addressTextView.isScrollEnabled = false
        addressTextView.layer.borderWidth = 1
        addressTextView.layer.borderColor = CGColor.init(red: 209/255, green: 209/255, blue: 214/255, alpha: 1)
        addressTextView.font = addressTextView.font?.withSize(15)
        addressTextView.backgroundColor = .white
        addressTextView.textColor = .black
        
        view.addSubview(latitudeLabel)
        latitudeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            latitudeLabel.topAnchor.constraint(equalTo: addressTextView.bottomAnchor, constant: 10),
            latitudeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20)
        ])
        latitudeLabel.backgroundColor = .white
        latitudeLabel.textColor = .systemGray
        latitudeLabel.font = latitudeLabel.font.withSize(12)
        latitudeLabel.text = "Широта"
        
        view.addSubview(latitudeTextView)
        latitudeTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            latitudeTextView.topAnchor.constraint(equalTo: latitudeLabel.bottomAnchor, constant: 5),
            latitudeTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            latitudeTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20)
        ])
        latitudeTextView.layer.cornerRadius = 5
        latitudeTextView.isScrollEnabled = false
        latitudeTextView.layer.borderWidth = 1
        latitudeTextView.layer.borderColor = CGColor.init(red: 209/255, green: 209/255, blue: 214/255, alpha: 1)
        latitudeTextView.font = latitudeTextView.font?.withSize(15)
        latitudeTextView.isEditable = false
        latitudeTextView.backgroundColor = .white
        latitudeTextView.textColor = .black
        
        view.addSubview(longitudeLabel)
        longitudeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            longitudeLabel.topAnchor.constraint(equalTo: latitudeTextView.bottomAnchor, constant: 10),
            longitudeLabel.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20)
        ])
        longitudeLabel.backgroundColor = .white
        longitudeLabel.textColor = .systemGray
        longitudeLabel.font = longitudeLabel.font.withSize(12)
        longitudeLabel.text = "Долгота"
        
        view.addSubview(longitudeTextView)
        longitudeTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            longitudeTextView.topAnchor.constraint(equalTo: longitudeLabel.bottomAnchor, constant: 5),
            longitudeTextView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            longitudeTextView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20)
        ])
        longitudeTextView.layer.cornerRadius = 5
        longitudeTextView.isScrollEnabled = false
        longitudeTextView.layer.borderWidth = 1
        longitudeTextView.layer.borderColor = CGColor.init(red: 209/255, green: 209/255, blue: 214/255, alpha: 1)
        longitudeTextView.font = longitudeTextView.font?.withSize(15)
        longitudeTextView.isEditable = false
        longitudeTextView.backgroundColor = .white
        longitudeTextView.textColor = .black
        
        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: longitudeTextView.bottomAnchor, constant: 15),
            cancelButton.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            cancelButton.widthAnchor.constraint(equalToConstant: 200),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        cancelButton.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
        cancelButton.setTitle("Сохранить", for: .normal)
        cancelButton.isHidden = true
        cancelButton.addTarget(self, action: #selector(saveChanges), for: .touchUpInside)
    }

    //Сохранить измененённую точку и вернуться к контроллеру с картой
    @objc
    private func saveChanges() {
        MapViewController.oldPoint = point.mark
        MapViewController.newPoint = suggestResults.first!
        NotificationCenter.default.post(name: Notification.Name("pointDidChanged"), object: nil)
        navigationController?.popViewController(animated: true)
    }

    //Создать сеанс для поиска адреса
    private func createSuggestSession() {
        suggestSession = searchManager.createSuggestSession()
    }

}

//MARK: - Extension
extension PointDescriptionViewController: UITableViewDelegate, UITableViewDataSource {

    //MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = suggestResults[indexPath.row].displayText
        cell.textLabel?.sizeToFit()
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.backgroundColor = .white
        cell.textLabel?.textColor = .black
        cell.contentView.backgroundColor = .white
        cell.backgroundColor = .white
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addressTextView.text = suggestResults[indexPath.row].displayText
        removeDropDownView()
        view.endEditing(true)
        cancelButton.isHidden = false
    }

    //MARK: - Private mathods

    private func setTableView() {
        dropDownTableView.delegate = self
        dropDownTableView.dataSource = self
        dropDownTableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    //Отобразить всплывающий список
    private func addDropDownView() {
        let frames = addressTextView.frame
        let window = UIApplication.shared.inputView?.window
        dropDownView.frame = window?.frame ?? self.view.frame
        dropDownView.backgroundColor = .white
        self.view.addSubview(dropDownView)
        
        dropDownTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        self.view.addSubview(dropDownTableView)
        dropDownTableView.layer.cornerRadius = 5
        dropDownTableView.backgroundColor = .white
        dropDownView.alpha = 0
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.dropDownView.alpha = 0.5
            self.dropDownTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height + 5, width: frames.width, height: CGFloat(self.suggestResults.count * 25))
        }, completion: nil)
    }

    //Свернуть всплывающий список
    private func removeDropDownView() {
        let frames = addressTextView.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.dropDownView.alpha = 0
            self.dropDownTableView.frame = CGRect(x: frames.origin.x, y: frames.origin.y + frames.height, width: frames.width, height: 0)
        }, completion: nil)
    }
    
}

//MARK: - Extension

extension PointDescriptionViewController: UITextViewDelegate {

    //MARK: - Public methods

    //Найти адрес по введенному тексту
    func textViewDidChange(_ textView: UITextView) {
        let suggestHandler = {(response: [YMKSuggestItem]?, error: Error?) -> Void in
            if let items = response {
                self.onSuggestResponse(items)
            } else {
                self.onSuggestError(error!)
            }
        }
        suggestSession.suggest(
            withText: textView.text!,
            window: boundingBox,
            suggestOptions: suggestOptions,
            responseHandler: suggestHandler)
        addDropDownView()
    }

    //Добавить результаты поиска в таблицу
    func onSuggestResponse(_ items: [YMKSuggestItem]) {
        suggestResults = items
        dropDownTableView.reloadData()
    }

    //Отобразить ошибку
    func onSuggestError(_ error: Error) {
        let suggestError = (error as NSError).userInfo[YRTUnderlyingErrorKey] as! YRTError
        var errorMessage = "Unknown error"
        if suggestError.isKind(of: YRTNetworkError.self) {
            errorMessage = "Network error"
        } else if suggestError.isKind(of: YRTRemoteError.self) {
            errorMessage = "Remote server error"
        }
        
        let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }

    //MARK: - Private methods

    private func delegateAddressTextView() {
        addressTextView.delegate = self
    }
}
