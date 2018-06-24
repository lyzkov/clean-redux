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
import Action

class MovieCategoriesViewController: UIViewController {
    
    let cellId = R.reuseIdentifier.movie_category.identifier
    
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    
    let paginationTrigger = Observable<Int>.interval(3.0, scheduler: MainScheduler.instance).ignoreAll()
    
    let cyclone = MovieCategoriesCyclone()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cyclone.output(\.categories)
            .bind(to: tableView.rx.items(cellIdentifier: cellId)) { (_, element, cell: UITableViewCell) in
                cell.textLabel?.text = element.name // TODO: bind directly to cells inputs
            }
            .disposed(by: disposeBag)

        cyclone.pagination.execute(action: .next)
//        paginationTrigger
//            .bind(to: cyclone.pagination.actions[.next]!.inputs)
//            .disposed(by: disposeBag)
    }

}


