//
//  CityCovidView.swift
//  CovidWidgetExtension
//
//  Created by 葉家均 on 2022/5/16.
//

import SwiftUI
import WidgetKit

struct CityCovidView: View {
    var entry: CityCovidEntry
    
    var body: some View {
        if entry.isError {
            Text(NSLocalizedString("NetworkError", comment: ""))
                .foregroundColor(.gray)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
                .padding(.horizontal)
        } else {
            VStack {
                Text(entry.cityData!.cityName)
                    .font(.body)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                HStack{
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 8){
                        Text(NSLocalizedString("TotalCases", comment: ""))
                            .font(.system(.subheadline, design: .rounded))
                        Text(entry.cityData!.totalCasesAmount)
                            .font(.system(size: 82, weight: .bold, design: .rounded)
                            )
                            .minimumScaleFactor(0.4)
                            .foregroundColor(Color("ColorRed"))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .center, spacing: 8){
                        Text(NSLocalizedString("NewCases", comment: ""))                      .font(.system(.subheadline, design: .rounded))
                        Text(entry.cityData!.newCasesAmount)
                            .font(.system(size: 82, weight: .bold, design: .rounded)
                            )
                            .minimumScaleFactor(0.4)
                            .foregroundColor(Color("ColorBlue"))
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                Text(NSLocalizedString("LastUpdate", comment: "").replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "{date}", with: entry.cityData!.announcementDate).replacingOccurrences(of: "-", with: "."))
                    .font(.system(.caption, design: .rounded))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)
                    .foregroundColor(.gray)
            }
            .padding()
        }
    }
}

struct CityCovidView_Previews: PreviewProvider {
    static var previews: some View {
        CityCovidView(entry: CityCovidEntry.fackData)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
