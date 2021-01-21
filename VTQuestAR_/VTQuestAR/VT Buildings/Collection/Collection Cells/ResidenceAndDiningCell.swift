
import UIKit

//set up layout constraint, title, and image for residenceAndDining cell.

class ResidenceAndDiningCell: UICollectionViewCell {
    
   
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
        
        buildingNameLabel.numberOfLines = 2
        buildingNameLabel.translatesAutoresizingMaskIntoConstraints = false
        buildingNameLabel.textColor = .gray
        buildingNameLabel.font = .systemFont(ofSize: 14)
        
        
        contentView.addSubview(self.imageView)
        contentView.addSubview(self.buildingNameLabel)
        imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1).isActive = true
        imageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1).isActive = true
        buildingNameLabel.topAnchor.constraint(equalTo: self.imageView.bottomAnchor).isActive = true
        buildingNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        buildingNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        buildingNameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}



