//
//  CameraCoordinator.swift
//  HotChal
//
//  Created by heojiwoo on 8/6/25.
//
import UIKit

protocol CameraCoordinatorDelegate: AnyObject {
    func cameraCoordinatorDidFinishWithVideo(url: URL)
}

final class CameraCoordinator: BaseCoordinator {
    
    weak var delegate: CameraCoordinatorDelegate?
    
    private let audioFileName: String
    
    init(navigationController: UINavigationController, audioFileName: String) {
        self.audioFileName = audioFileName
        super.init(navigationController)
    }
    
    required init(_ navigationController: UINavigationController) {
        fatalError("init(_:) has not been implemented")
    }
    
    override func start() {
        let cameraVC = CameraViewController()
        cameraVC.audioFileName = audioFileName
        cameraVC.delegate = self
        cameraVC.modalPresentationStyle = .fullScreen
        navigationController.present(cameraVC, animated: true)
    }
}

// MARK: - CameraViewControllerDelegate
extension CameraCoordinator: CameraViewControllerDelegate {
    
    func cameraViewControllerDidFinishRecording(videoURL: URL) {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.delegate?.cameraCoordinatorDidFinishWithVideo(url: videoURL)
            self?.finish()
        }
    }

    func cameraViewControllerDidCancel() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
}
