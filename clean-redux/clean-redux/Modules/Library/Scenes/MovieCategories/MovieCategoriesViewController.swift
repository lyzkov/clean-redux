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
    
    let cellId = R.reuseIdentifier.movie_category.identifier
    let disposeBag = DisposeBag()
    
    let paginationTrigger = Observable<Int>.interval(3.0, scheduler: MainScheduler.instance).ignoreAll()
    
    let cyclone = MovieCategoriesCyclone()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cyclone.state.map { $0.categories.map { $0.name } }
            .bind(to: tableView.rx.items(cellIdentifier: cellId)) { (_, element, cell: UITableViewCell) in
                cell.textLabel?.text = element // TODO: bind directly to cells inputs
            }
            .disposed(by: disposeBag)

        cyclone.actions[.load]!.execute(())
        paginationTrigger
            .bind(to: cyclone.pagination.actions[.next]!.inputs)
            .disposed(by: disposeBag)
    }

}


