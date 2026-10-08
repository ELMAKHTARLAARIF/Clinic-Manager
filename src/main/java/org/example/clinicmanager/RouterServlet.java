package org.example.clinicmanager;

import com.clinicmanager.controller.AdminController.DepartmentController;
import com.clinicmanager.controller.AdminController.DoctorController;
import com.clinicmanager.controller.AdminController.PatientController;
import com.clinicmanager.controller.AuthController.LoginController;
import com.clinicmanager.controller.AuthController.RegisterController;
import com.clinicmanager.controller.DoctorController.AvailabilityController;
import com.clinicmanager.controller.DoctorController.AvailabilityController;
import com.clinicmanager.controller.DoctorController.BookingController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/")
public class RouterServlet extends HttpServlet {

    /** Une route = une méthode qui reçoit la requête et la réponse. */
    @FunctionalInterface
    private interface Handler {
        void handle(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException;
    }

    private final LoginController loginController = new LoginController();
    private final RegisterController registerController = new RegisterController();
    private final DoctorController doctorController = new DoctorController();
    private final PatientController patientController = new PatientController();
    private final DepartmentController departmentController = new DepartmentController();
    private final AvailabilityController availabilityController = new AvailabilityController();
    private final BookingController bookingController = new BookingController();


    private final Map<String, Handler> getRoutes = new HashMap<>();
    private final Map<String, Handler> postRoutes = new HashMap<>();

    @Override
    public void init() {

        getRoutes.put("", view("index.jsp"));
        getRoutes.put("/", view("index.jsp"));
        getRoutes.put("/login", view("auth/login.jsp"));
        getRoutes.put("/register", view("auth/register.jsp"));
        getRoutes.put("/admin/dashboard", view("admin/dashboard.jsp"));
        getRoutes.put("/admin/specialties", view("admin/specialties.jsp"));
        getRoutes.put("/admin/users", view("admin/users.jsp"));

        getRoutes.put("/admin/patients", patientController::list);

        getRoutes.put("/admin/patients/get", patientController::getPatient);
        getRoutes.put("/admin/doctors", doctorController::list);
        getRoutes.put("/admin/departments", departmentController::list);

        postRoutes.put("/login", loginController::login);
        postRoutes.put("/register", registerController::register);
        postRoutes.put("/admin/doctor/create", doctorController::createDoctor);
        postRoutes.put("/admin/patients/create", patientController::createPatient);
        postRoutes.put("/admin/patients/update", patientController::updatePatient);
        postRoutes.put("/admin/patients/delete", patientController::deletePatient);
        getRoutes.put("/logout", (req, res) -> {
            HttpSession session = req.getSession(false);
            if (session != null) session.invalidate();
            res.sendRedirect(req.getContextPath() + "/login");
        });


        getRoutes.put("/doctor/dashboard", view("doctor/dashboard.jsp"));
        getRoutes.put("/doctor/appointments", view("doctor/appointments.jsp"));
        
        getRoutes.put("/doctor/availabilities", availabilityController::list);
        postRoutes.put("/doctor/availabilities/create", availabilityController::create);
        postRoutes.put("/doctor/availabilities/delete", availabilityController::delete);


         getRoutes.put("/patient/book", bookingController::page);
        getRoutes.put("/patient/agenda", bookingController::agendaJson);
       // the JSON endpoint
//        postRoutes.put("/patient/appointments/create", appointmentController::create);


    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Handler handler = getRoutes.get(getPath(req));
        if (handler != null) {
            handler.handle(req, res);
        } else {
            getServletContext().getNamedDispatcher("default").forward(req, res);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
        Handler handler = postRoutes.get(getPath(req));
        if (handler != null) {
            handler.handle(req, res);
        } else {
            res.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
        }
    }


    /** Route vers une simple page JSP. */
    private Handler view(String name) {
        return (req, res) -> req.getRequestDispatcher("/WEB-INF/views/" + name).forward(req, res);
    }

    private String getPath(HttpServletRequest request) {
        return request.getRequestURI().substring(request.getContextPath().length());
    }
}