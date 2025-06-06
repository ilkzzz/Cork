//
//  Brew Pane.swift
//  Cork
//
//  Created by David Bureš on 06.03.2023.
//

import Foundation
import SwiftUI
import CorkShared

struct BrewPane: View
{
    @AppStorage("strictlyCheckForHomebrewErrors") var strictlyCheckForHomebrewErrors: Bool = false

    @AppStorage("allowBrewAnalytics") var allowBrewAnalytics: Bool = true
    @AppStorage("allowAdvancedHomebrewSettings") var allowAdvancedHomebrewSettings: Bool = false

    @EnvironmentObject var settingsState: SettingsState

    @State private var isPerformingBrewAnalyticsChangeCommand: Bool = false

    var body: some View
    {
        SettingsPaneTemplate
        {
            VStack(spacing: 10)
            {
                Form
                {
                    LabeledContent
                    {
                        Toggle(isOn: $strictlyCheckForHomebrewErrors)
                        {
                            Text("settings.brew.strictly-check-for-errors")
                        }
                    } label: {
                        Text("settings.brew.error-checking")
                    }

                    LabeledContent
                    {
                        Toggle(isOn: $allowBrewAnalytics)
                        {
                            Text("settings.brew.collect-analytics")
                        }
                        .disabled(isPerformingBrewAnalyticsChangeCommand)
                    } label: {
                        Text("settings.brew.analytics")
                    }
                }
                .onChange(of: allowBrewAnalytics)
                { newValue in
                    if newValue == true
                    {
                        Task
                        {
                            isPerformingBrewAnalyticsChangeCommand = true

                            AppConstants.shared.logger.debug("Will ENABLE analytics")
                            await shell(AppConstants.shared.brewExecutablePath, ["analytics", "on"])

                            isPerformingBrewAnalyticsChangeCommand = false
                        }
                    }
                    else if newValue == false
                    {
                        Task
                        {
                            isPerformingBrewAnalyticsChangeCommand = true

                            AppConstants.shared.logger.debug("Will DISABLE analytics")
                            await shell(AppConstants.shared.brewExecutablePath, ["analytics", "off"])

                            isPerformingBrewAnalyticsChangeCommand = false
                        }
                    }
                }

                Divider()

                VStack(alignment: .center)
                {
                    Toggle(isOn: $allowAdvancedHomebrewSettings, label: {
                        Text("settings.brew.enable-advanced-settings")
                    })
                    .toggleStyle(.switch)

                    Text("settings.brew.custom-homebrew-path.will-not-bother-me-with-support")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                CustomHomebrewExecutableView()
            }
        }
    }
}
