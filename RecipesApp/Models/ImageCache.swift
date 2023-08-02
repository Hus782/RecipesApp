/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The Image cache.
*/
import UIKit

struct ImageRequestResponse {
    let image: UIImage
    let url: URL
    let cost: Int
}

public class ImageCache {
    
    public static let publicCache = ImageCache()
    private let cachedImages: NSCache<NSURL, UIImage>
    private let client: HTTPClientProtocol
    private let placeHolderImage = UIImage(named: "placeholder")!
    
    init(client: HTTPClientProtocol = HTTPClient(), cache: NSCache<NSURL, UIImage> = .init()) {
        self.client = client
        self.cachedImages = cache
    }
    
    private func image(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    func load(url: NSURL, completion: @escaping (UIImage?) -> Void) {
        // Check for a cached image.
        if let cachedImage = image(url: url) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        // Go fetch the image.
        client.downloadImage(url: url as URL, completion: {
            result in
            switch result {
            case .success(let results):
                self.cachedImages.setObject(results.image, forKey: results.url as NSURL, cost: results.cost)
                DispatchQueue.main.async {
                    completion(results.image)
                }
            case .failure:
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        })
    }
}
