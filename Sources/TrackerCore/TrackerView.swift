import AppKit
import SwiftUI

public struct TrackerView: View {
    @Bindable var store: Store
    @State private var editing: Application?

    public init(store: Store) { self.store = store }

    public var body: some View {
        ZStack {
            Theme.page.ignoresSafeArea()
            Nebel()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    ForEach([store.loadProblem, store.saveError].compactMap { $0 }, id: \.self) { message in
                        Text(message)
                            .font(Theme.text(13)).foregroundStyle(Theme.rot)
                            .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.rot.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                    }
                    AddForm { store.applications.insert($0, at: 0) }
                    if store.applications.isEmpty {
                        Text("Add your first application")
                            .font(Theme.text()).foregroundStyle(Theme.secondary)
                            .frame(maxWidth: .infinity).padding(.vertical, 40)
                    }
                    ForEach($store.applications) { $app in
                        Row(app: $app, onEdit: { editing = app }) {
                            store.applications.removeAll { $0.id == app.id }
                        }
                    }
                }
                .padding(32)
                .frame(maxWidth: 820)
                .frame(maxWidth: .infinity)
            }
        }
        .foregroundStyle(Theme.ink)
        .sheet(item: $editing) { app in
            EditSheet(app: app) { changed in
                if let i = store.applications.firstIndex(where: { $0.id == changed.id }) { store.applications[i] = changed }
            }
        }
    }

    private var header: some View {
        let c = Counts(store.applications)
        return VStack(alignment: .leading, spacing: 8) {
            Text("APPLICATION TRACKER").font(Theme.mono(11)).tracking(0.9).foregroundStyle(Theme.muted)
            Text("My applications").font(Theme.head(44)).tracking(-1.3)
            Text("\(c.total) total · \(c.sent) sent · \(c.replies) replies · \(c.interviews) interviews")
                .font(Theme.mono(13)).foregroundStyle(Theme.secondary)
        }
    }
}

struct AddForm: View {
    let add: (Application) -> Void
    @State private var company = ""
    @State private var role = ""
    @State private var link = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ADD APPLICATION").font(Theme.head(13))
            HStack {
                Field(placeholder: "Company", text: $company)
                Field(placeholder: "Role", text: $role)
            }
            Field(placeholder: "Link to the ad (optional)", text: $link)
            Button("Add") {
                add(Application(company: company.trimmed, role: role.trimmed, link: link.trimmed))
                company = ""; role = ""; link = ""
            }
            .buttonStyle(GepardButton(primary: true))
            .disabled(company.trimmed.isEmpty)
            .keyboardShortcut(.defaultAction)
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.edge, style: StrokeStyle(lineWidth: 1, dash: [4, 3])))
    }
}

struct Row: View {
    @Binding var app: Application
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var confirmDelete = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.company).font(Theme.medium(15))
                    if !app.role.isEmpty { Text(app.role).font(Theme.text()).foregroundStyle(Theme.secondary) }
                }
                Spacer()
                StatusMenu(app: $app)
            }
            HStack(spacing: 12) {
                Text(app.sentDate.map { "Sent " + $0.formatted(date: .abbreviated, time: .omitted) } ?? "Not sent yet")
                    .font(Theme.mono(11)).foregroundStyle(Theme.muted)
                if let url = app.url {
                    Link("Open ad ↗", destination: url).font(Theme.mono(11)).foregroundStyle(Theme.akzent)
                }
                Spacer()
                Button("Edit", action: onEdit).buttonStyle(GepardButton())
                Button("Delete") { confirmDelete = true }.buttonStyle(GepardButton(destructive: true))
            }
            TextField("Notes (contact person, next step …)", text: $app.note, axis: .vertical)
                .textFieldStyle(.plain).font(Theme.text()).lineLimit(1...8)
                .padding(8)
                .background(Theme.field, in: RoundedRectangle(cornerRadius: 4))
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Theme.edge))
        }
        .padding(16)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.edge))
        .confirmationDialog("Delete the application at \(app.company)?", isPresented: $confirmDelete) {
            Button("Delete", role: .destructive, action: onDelete)
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct StatusMenu: View {
    @Binding var app: Application

    var body: some View {
        let color = Theme.color(for: app.status)
        let filled = app.status == .interview
        Menu {
            ForEach(Status.allCases) { status in
                Button(status.title) { app.setStatus(status) }
            }
        } label: {
            HStack(spacing: 6) {
                Circle().fill(filled ? Theme.onPrimary : color).frame(width: 7, height: 7)
                Text(app.status.title).font(Theme.mono(12))
            }
            .padding(.horizontal, 10).padding(.vertical, 4)
            .foregroundStyle(filled ? Theme.onPrimary : Theme.ink)
            .background(filled ? color : .clear, in: Capsule())
            .overlay(Capsule().stroke(color))
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityLabel("Status: \(app.status.title)")
    }
}

struct EditSheet: View {
    @State var app: Application
    let save: (Application) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("EDIT APPLICATION").font(Theme.head(13))
            Field(placeholder: "Company", text: $app.company)
            Field(placeholder: "Role", text: $app.role)
            Field(placeholder: "Link to the ad", text: $app.link)
            Toggle("Sent", isOn: Binding(get: { app.sentDate != nil },
                                         set: { app.sentDate = $0 ? (app.sentDate ?? .now) : nil }))
                .font(Theme.text())
            if let sent = app.sentDate {
                DatePicker("Sent on", selection: Binding(get: { sent }, set: { app.sentDate = $0 }),
                           displayedComponents: .date)
                    .font(Theme.text())
            }
            HStack {
                Spacer()
                Button("Cancel") { dismiss() }.buttonStyle(GepardButton()).keyboardShortcut(.cancelAction)
                Button("Save") { save(app); dismiss() }
                    .buttonStyle(GepardButton(primary: true))
                    .disabled(app.company.trimmed.isEmpty)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 420)
        .background(Theme.page)
        .foregroundStyle(Theme.ink)
    }
}

extension Application {
    /// Links typed without a scheme ("example.com/job") still open.
    var url: URL? {
        let text = link.trimmed
        return text.isEmpty ? nil : URL(string: text.contains("://") ? text : "https://" + text)
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}

extension Store {
    /// Menu item "Show Data in Finder" (FT-10).
    public func showInFinder() {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            NSWorkspace.shared.activateFileViewerSelecting([fileURL])
        } else {
            NSWorkspace.shared.open(directory)
        }
    }
}
