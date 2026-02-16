// Selenium WebDriver — Login Test with Page Object Model
// Language: Java
// Framework: Selenium WebDriver + TestNG + Page Object Model
// Purpose: Demonstrates automated regression testing for login feature

// ─────────────────────────────────────────
// FILE 1: LoginPage.java (Page Object)
// ─────────────────────────────────────────

import org.openqa.selenium.By;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import java.time.Duration;

/**
 * Page Object for the Login Page.
 * Contains all locators and actions for the login page.
 * If any UI element changes, only this class needs updating.
 */
public class LoginPage {

    private WebDriver driver;
    private WebDriverWait wait;

    // Locators — defined once, used everywhere
    private By emailField = By.id("email");
    private By passwordField = By.id("password");
    private By loginButton = By.id("login-btn");
    private By errorMessage = By.id("error-message");
    private By welcomeMessage = By.id("welcome-msg");

    // Constructor
    public LoginPage(WebDriver driver) {
        this.driver = driver;
        this.wait = new WebDriverWait(driver, Duration.ofSeconds(10));
    }

    // Actions

    /**
     * Enter email address into the email field.
     */
    public void enterEmail(String email) {
        wait.until(ExpectedConditions.visibilityOfElementLocated(emailField));
        driver.findElement(emailField).clear();
        driver.findElement(emailField).sendKeys(email);
    }

    /**
     * Enter password into the password field.
     */
    public void enterPassword(String password) {
        driver.findElement(passwordField).clear();
        driver.findElement(passwordField).sendKeys(password);
    }

    /**
     * Click the login button.
     */
    public void clickLogin() {
        wait.until(ExpectedConditions.elementToBeClickable(loginButton));
        driver.findElement(loginButton).click();
    }

    /**
     * Complete login flow in one method.
     */
    public void login(String email, String password) {
        enterEmail(email);
        enterPassword(password);
        clickLogin();
    }

    /**
     * Get error message text after failed login.
     */
    public String getErrorMessage() {
        wait.until(ExpectedConditions.visibilityOfElementLocated(errorMessage));
        return driver.findElement(errorMessage).getText();
    }

    /**
     * Get welcome message text after successful login.
     */
    public String getWelcomeMessage() {
        wait.until(ExpectedConditions.visibilityOfElementLocated(welcomeMessage));
        return driver.findElement(welcomeMessage).getText();
    }

    /**
     * Check if login was successful by verifying welcome message is displayed.
     */
    public boolean isLoginSuccessful() {
        try {
            wait.until(ExpectedConditions.visibilityOfElementLocated(welcomeMessage));
            return driver.findElement(welcomeMessage).isDisplayed();
        } catch (Exception e) {
            return false;
        }
    }
}


// ─────────────────────────────────────────
// FILE 2: LoginTest.java (Test Class)
// ─────────────────────────────────────────

import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.testng.Assert;
import org.testng.annotations.AfterMethod;
import org.testng.annotations.BeforeMethod;
import org.testng.annotations.Test;

/**
 * Test class for Login feature.
 * Covers: positive login, invalid password, empty fields.
 * Uses Page Object Model — tests call LoginPage methods, not elements directly.
 */
public class LoginTest {

    private WebDriver driver;
    private LoginPage loginPage;
    private static final String BASE_URL = "https://example.com/login";

    @BeforeMethod
    public void setUp() {
        // Initialize ChromeDriver
        driver = new ChromeDriver();
        driver.manage().window().maximize();
        driver.get(BASE_URL);
        loginPage = new LoginPage(driver);
    }

    /**
     * TC-001: Valid credentials should log in successfully.
     */
    @Test(description = "TC-001: Valid login — happy path")
    public void testValidLogin() {
        loginPage.login("testuser@example.com", "ValidPass123!");

        Assert.assertTrue(loginPage.isLoginSuccessful(),
            "Login failed — welcome message not displayed after valid credentials");
    }

    /**
     * TC-002: Invalid password should show error message.
     */
    @Test(description = "TC-002: Invalid password — negative test")
    public void testInvalidPassword() {
        loginPage.login("testuser@example.com", "WrongPassword");

        String errorMsg = loginPage.getErrorMessage();
        Assert.assertEquals(errorMsg, "Invalid email or password",
            "Expected error message not displayed after invalid password");
    }

    /**
     * TC-003: Empty fields should show validation messages.
     */
    @Test(description = "TC-003: Empty fields — validation test")
    public void testEmptyFields() {
        loginPage.clickLogin(); // Click without entering any credentials

        // Verify form did not submit — user stays on login page
        Assert.assertTrue(driver.getCurrentUrl().contains("/login"),
            "Form submitted with empty fields — should have been prevented");
    }

    @AfterMethod
    public void tearDown() {
        if (driver != null) {
            driver.quit();
        }
    }
}
