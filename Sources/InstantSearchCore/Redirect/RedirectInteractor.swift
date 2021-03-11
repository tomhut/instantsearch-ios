//
//  RedirectInteractor.swift
//  
//
//  Created by Vladislav Fitc on 11/03/2021.
//

import Foundation

public class RedirectInteractor: ItemInteractor<Redirect?> {
  
  public override init(item: Redirect? = nil) {
    super.init(item: item)
  }

  func extractRedirect(from searchResponse: SearchResponse) {
    item = searchResponse.rules?.consequence?.renderingContent?.redirect
  }
  
}

public extension RedirectInteractor {

  /// Connection between a rule custom data logic and a single index searcher
  struct SearcherConnection<Searcher: SearchResultObservable>: Connection where Searcher.SearchResult == SearchResponse {

    /// Logic applied to the custom model
    public let interactor: RedirectInteractor

    /// Searcher that handles your searches
    public let searcher: Searcher

    /**
     - Parameters:
       - interactor: Interactor to connect
       - searcher: SearchResultObservable implementation to connect
    */
    public init(interactor: RedirectInteractor, searcher: Searcher) {
      self.searcher = searcher
      self.interactor = interactor
    }

    public func connect() {
      searcher.onResults.subscribe(with: interactor) { (interactor, searchResponse) in
        interactor.extractRedirect(from: searchResponse)
      }
    }

    public func disconnect() {
      searcher.onResults.cancelSubscription(for: interactor)
      (searcher as? ErrorObservable)?.onError.cancelSubscription(for: interactor)
    }

  }
  
  @discardableResult func connectSearcher<Searcher: SearchResultObservable>(_ searcher: Searcher) -> SearcherConnection<Searcher> {
    let connection = SearcherConnection(interactor: self, searcher: searcher)
    connection.connect()
    return connection
  }

}

