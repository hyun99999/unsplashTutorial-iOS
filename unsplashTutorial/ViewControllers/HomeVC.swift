//
//  ViewController.swift
//  unsplashTutorial
//
//  Created by kimhyungyu on 2021/01/23.
//

import UIKit
import Toast_Swift

class HomeVC: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var searchFilterSegment: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var searchIndicator: UIActivityIndicatorView!
    
    var keyboardDismissTabGesture : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: nil)
    
    //MARK: - override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("HomeVC - viewDidLoad() called")
        config()
    }

    //MARK: - fileprivate methods
    fileprivate func config(){
        //UI설정
        searchBtn.layer.cornerRadius = 10
        searchBar.searchBarStyle = .minimal
        //searchBar delegate 연결
        self.searchBar.delegate = self
        //UIGestureReconizerDelegate 연결
        self.keyboardDismissTabGesture.delegate = self
        //최상단 뷰에 접근. 누르면 키보드를 내리기 위해서
        self.view.addGestureRecognizer(keyboardDismissTabGesture)
       //화면 로드 시 키보드 포커싱 추가
        self.searchBar.becomeFirstResponder()
    }
    
    fileprivate func pushVC() {
        //미리 스토리보드에서 정해둔 세그로 화면이동
        var segueID : String = ""
        switch searchFilterSegment.selectedSegmentIndex {
        case 0:
            print("사진 화면으로이동")
            segueID = "goToPhotoCollectionVC"
        case 1:
            print("사용자 화면으로 이동")
            segueID = "goToUserListVC"
        default:
            print("default")
            segueID = "goToPhotoCollectionVC"
        }
        //세그를 이용한 네비게이션 화면이동
        self.performSegue(withIdentifier: segueID, sender: self)
    }
    
    //MARK: - @IBAction methods
    @IBAction func searchFilterValueChanged(_ sender: UISegmentedControl) {
//        print("HomeVC - searchFilterValueChanged() called \(sender.selectedSegmentIndex )")
        var searchBarTitle = ""
        switch sender.selectedSegmentIndex {
        case 0:
            searchBarTitle = "사진 키워드"
        case 1:
            searchBarTitle = "사용자 이름"
        default:
            searchBarTitle = "사진 키워드"
        }
        self.searchBar.placeholder = searchBarTitle + " 입력"
        //키보드 포커싱을 준다. searchFilter 값이 변할경우 즉 sindicatior 가 변할 때 키보드가 올라온다.
        self.searchBar.becomeFirstResponder()
    }
    
    @IBAction func onSearchBtnClicked(_ sender: UIButton) {
        print("HomeVC - onSearchBtnClicked() called \(searchFilterSegment.selectedSegmentIndex)")
        //화면 이동
        pushVC()
    }
    
    //MAKR: - UISearchBar Delegate methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("HomeVC - searchBarSearchButtonClicked() called")
        guard let userInputString = searchBar.text else { return }
        if userInputString.isEmpty {
            self.view.makeToast("🤨 검색 키워드를 입력해주세요.", duration: 1.0, position: .center)
        } else {
            //입력값이 있다면 화면이동
            pushVC()
            searchBar.resignFirstResponder()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("HomeVC - searchBar textDidChange() searchText: \(searchText)")
        
        if searchText.isEmpty {
            self.searchBtn.isHidden = true
            //약간의 딜레이를 주어서 비동기 처리할 것. searchBar 의 전체삭제를 누르면 삭제되서 내려가야하는데 bar 를 누르는 것이라서 키보드가 내려가지 않는 문제.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: {
                                            searchBar.resignFirstResponder()
            })
            //키보드 포커싱 해제
        } else {
            self.searchBtn.isHidden = false
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let inputTextCount = searchBar.text?.appending(text).count ?? 0
        print("shouldChangeTextIn: \(inputTextCount)")
        //위의 searchBar 함수보다 이 함수가 더 빠르기 때문에(shoudlChangedTextIn) 여기에 설정해야 13자가 화면상으로 입력되기 전에 설정 가능.
        if inputTextCount >= 12 {
            // toast with a specific duration and position
            self.view.makeToast("🧐 12자까지만 입력가능합니다.", duration: 1.0, position: .center)
        }
        //12자까지만 입력. 13자부터는 false 로 searchBar 에 입력이 되지 않는다.
        if inputTextCount <= 12 {
            return true
        } else {
            return false
        }
        //return inputTextCount <= 12 와 같다.
    }
    
    //MARK: - UIGestureReconizerDelegate methods
    //keyboard dismiss 를 위한 제스쳐 등록
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        print("HomeVC - gestureRecongnizer() called")
        
        //특정한 요소에 대해서 예외처리(searchBar, segmentIndicator)
        if touch.view?.isDescendant(of: searchFilterSegment) == true {
            return false
        } else if touch.view?.isDescendant(of: searchBar) == true {
            return false
        } else {
            view.endEditing(true)
            return true
        }
        
    }
}
