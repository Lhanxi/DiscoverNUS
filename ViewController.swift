import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            guard let self = self else { return }
            if let error = error {
                self.messageLabel.text = "Error logging in: \(error.localizedDescription)"
            } else {
                self.performSegue(withIdentifier: "LoginToMyView", sender: self)
            }
        }
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "SignUpPage", sender: self)
    }
}

class MyViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
    }
}

class SignUpViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
    }
    
    @IBAction func signupButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (user, error) in
            guard let self = self else { return }
            if let error = error {
                self.messageLabel.text = "Error signing up: \(error.localizedDescription)"
            } else {
                self.messageLabel.text = "Sign up successful!"
            }
        }
    }
}
