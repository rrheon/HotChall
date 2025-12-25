//
//  CameraCoordinator.swift
//  HotChal
//
//  Created by heojiwoo on 8/6/25.
//
import UIKit

protocol CameraCoordinatorDelegate: AnyObject {
    func cameraCoordinatorDidFinishWithVideo(url: URL, subVideoFilename: String?)
}

final class CameraCoordinator: BaseCoordinator {

    weak var delegate: CameraCoordinatorDelegate?

    private let audioFileName: String
    private let subVideoFilename: String?

    init(navigationController: UINavigationController, audioFileName: String, subVideoFilename: String? = nil) {
        self.audioFileName = audioFileName
        self.subVideoFilename = subVideoFilename
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
            self?.delegate?.cameraCoordinatorDidFinishWithVideo(url: videoURL, subVideoFilename: self?.subVideoFilename)
            self?.finish()
        }
    }

    func cameraViewControllerDidCancel() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
}
