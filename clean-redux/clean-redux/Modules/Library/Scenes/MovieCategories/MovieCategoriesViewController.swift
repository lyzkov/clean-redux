//
//  MovieCategoriesFeedbackViewController.swift
//  clean-redux
//
//  Created by BOGU$ on 04/05/2018.
//  Copyright © 2018 lyzkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFeedback
import ReactorKit
import Action

class MovieCategoriesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    let paginationTrigger = Observable<Int>.interval(3.0, scheduler: MainScheduler.instance).map { _ in () }
    
    let cyclone = MovieCategoriesCyclone()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cyclone.categoryNames
            .bind(to:
                tableView.rx.items(
                    cellIdentifier: R.reuseIdentifier.movie_category.identifier,
                    cellType: UITableViewCell.self
                )
            ) { _, element, cell in
                cell.textLabel?.text = element // TODO: bind directly to cells inputs
            }
            .disposed(by: disposeBag)

        cyclone.loadAction.errors.debug().subscribe(onNext: { print($0) }).disposed(by: disposeBag)
        cyclone.loadAction.execute(())
        Observable<Int>.interval(3.0, scheduler: MainScheduler.instance)
            .map { _ in () }
            .bind(to: cyclone.pagination.nextAction.inputs)
            .disposed(by: disposeBag)
    }

}


