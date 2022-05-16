//
//  TaiwanCovidWidgetView.swift
//  TaiwanEpidemicStatus
//
//  Created by 葉家均 on 2022/5/16.
//

import Foundation
import SwiftUI
import WidgetKit

struct TaiwanCovidWidgetView : View {
    var entry:TaiwanCovidEntry
    
    var body: some View {
        if entry.isError {
            Text(NSLocalizedString("NetworkError", comment: ""))
                    .foregroundColor(.gray)
                    .minimumScaleFactor(0.7)
                    .padding(.horizontal)
            
        } else {
            VStack {
                Text(NSLocalizedString("TaiwanCovidWidgetTitle", comment: ""))
                    .font(.body)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                 
                Spacer()
                
                Text(entry.confirmCases)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .font(.system(size: 82, weight: .bold, design: .rounded))
                    .foregroundColor(Color.init("ColorRed"))
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    
                Spacer()
                
                Text(NSLocalizedString("LastUpdate", comment: "").replacingOccurrences(of: "{date}", with: entry.updateDate))
                    .minimumScaleFactor(0.4)
                    .lineLimit(2)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.gray)
            }
            .padding()
        }
        

    }
}

struct TaiwanCovidWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        TaiwanCovidWidgetView(entry: TaiwanCovidEntry.fackEntry())
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
