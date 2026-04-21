import SwiftUI

struct TrelloPanelView: View {
    var body: some View {
        TrelloWebView()
            .frame(minWidth: AppConstants.panelSize.width, minHeight: AppConstants.panelSize.height)
    }
}
