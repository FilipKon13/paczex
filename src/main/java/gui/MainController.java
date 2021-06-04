package gui;

import gui.admin.AdminWindow;
import gui.customer.CustomerWindow;
import gui.employee.EmployeeWindow;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import utility.Database;

public class MainController {
    public Label commandLabel;
    public TextField commandField;

    public void openAdmin() {
        AdminWindow.show();
    }

    public void openEmployee() {
        EmployeeWindow.show();
    }

    public void openCustomer() {
        CustomerWindow.show();
    }

    public void loadCommand() {
        Database.load(commandField.getText());
    }
}
