//
//  StartViewController.swift
//  Santehnika-online-Colchugina
//
//  Created by Ирина Кольчугина on 13.10.2021.
//

import UIKit

final class StartViewController: UIViewController {

    //MARK: - Private properties
    private let openMapButton = UIButton()

    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setViews()
    }

    //MARK: - Private methods
    private func setViews() {
        view.addSubview(openMapButton)
        openMapButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            openMapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            openMapButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            openMapButton.widthAnchor.constraint(equalToConstant: 200),
            openMapButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        openMapButton.addTarget(self, action: #selector(openMap), for: .touchUpInside)
        openMapButton.setTitle("Показать на карте", for: .normal)
        openMapButton.setTitleColor(.white, for: .normal)
        openMapButton.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 0/255, alpha: 1)
    }

    @objc
    private func openMap() {
        let vc = MapViewController()
        let backItem = UIBarButtonItem()
        backItem.title = ""
        self.navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(vc, animated: true)
    }

}

