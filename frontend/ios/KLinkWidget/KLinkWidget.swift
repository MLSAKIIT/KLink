import WidgetKit
import SwiftUI

struct KLinkWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.1)
                .ignoresSafeArea()
            
            if entry.hasData {
                VStack(alignment: .leading, spacing: 8) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("@\(entry.username)")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(entry.timestamp)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    
                    // Image
                    if let imageUrl = entry.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            case .failure:
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(8)
                        .padding(.horizontal, 12)
                    }
                    
                    // Content
                    Text(entry.content)
                        .font(.system(size: 13))
                        .foregroundColor(.white)
                        .lineLimit(3)
                        .padding(.horizontal, 12)
                    
                    Spacer()
                    
                    // Branding
                    Text("KLink")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 8)
                }
            } else {
                VStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text(entry.message)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), hasData: false, imageUrl: nil, username: "", name: "", content: "", timestamp: "", message: "Loading...")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), hasData: false, imageUrl: nil, username: "", name: "", content: "", timestamp: "", message: "No posts available")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Read data from UserDefaults shared with the app
        let sharedDefaults = UserDefaults(suiteName: "group.com.klink.frontend")
        
        let hasData = sharedDefaults?.bool(forKey: "hasData") ?? false
        
        if hasData {
            let imageUrl = sharedDefaults?.string(forKey: "imageUrl")
            let username = sharedDefaults?.string(forKey: "username") ?? ""
            let name = sharedDefaults?.string(forKey: "name") ?? ""
            let content = sharedDefaults?.string(forKey: "content") ?? ""
            let timestamp = sharedDefaults?.string(forKey: "timestamp") ?? ""
            
            let entry = SimpleEntry(
                date: Date(),
                hasData: true,
                imageUrl: imageUrl,
                username: username,
                name: name,
                content: content,
                timestamp: timestamp,
                message: ""
            )
            entries.append(entry)
        } else {
            let message = sharedDefaults?.string(forKey: "message") ?? "No posts available"
            let entry = SimpleEntry(date: Date(), hasData: false, imageUrl: nil, username: "", name: "", content: "", timestamp: "", message: message)
            entries.append(entry)
        }

        // Update every 30 minutes
        let timeline = Timeline(entries: entries, policy: .after(Date().addingTimeInterval(30 * 60)))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let hasData: Bool
    let imageUrl: String?
    let username: String
    let name: String
    let content: String
    let timestamp: String
    let message: String
}

@main
struct KLinkWidget: Widget {
    let kind: String = "KLinkWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            KLinkWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("KLink")
        .description("Shows latest posts from people you follow")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
