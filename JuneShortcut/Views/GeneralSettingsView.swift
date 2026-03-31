import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject var loginItemService = LoginItemService.shared
    @ObservedObject var hotkeyService = HotkeyService.shared
    @State private var accessibilityGranted = AccessibilityService.isGranted

    var body: some View {
        Form {
            Section("일반") {
                Toggle("로그인 시 자동 시작", isOn: $loginItemService.isEnabled)

                HStack {
                    Text("접근성 권한")
                    Spacer()
                    if accessibilityGranted {
                        Label("허용됨", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Button("권한 요청") {
                            AccessibilityService.requestAccess()
                        }
                        Label("필요함", systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                    }
                }
            }

            Section("상태") {
                HStack {
                    Text("글로벌 단축키")
                    Spacer()
                    Text(hotkeyService.isRunning ? "활성" : "비활성")
                        .foregroundColor(hotkeyService.isRunning ? .green : .secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 400, height: 200)
        .onAppear {
            accessibilityGranted = AccessibilityService.isGranted
        }
    }
}
