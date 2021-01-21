
import SwiftUI
//set up layout constraint, title, and image for athletic cell.

class AthleticCell: UICollectionViewCell {
    
    func setBuildingNameAndImage(building:Building) {
        imageView.image = UIImage(named: building.imageFilename!)
        buildingNameLabel.text = building.name
    }
    
    
    var imageView = UIImageView()
    
    var buildingNameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
                imageView.image = UIImage()
                imageView.translatesAutoresizingMaskIntoConstraints = false
        
                imageView.clipsToBounds = true
                imageView.layer.cornerRadius = 10
        buildingNameLabel.text = "TBD"
        buildingNameLabel.translatesAutoresizingMaskIntoConstraints = false
        buildingNameLabel.numberOfLines = 2
        buildingNameLabel.highlightedTextColor = .black
        buildingNameLabel.textColor = .gray
        self.addSubview(self.imageView)
        self.addSubview(self.buildingNameLabel)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.heightAnchor.constraint(equalTo: self.widthAnchor,multiplier: (3/2)),
            
            buildingNameLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor),
            buildingNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            buildingNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buildingNameLabel.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}

