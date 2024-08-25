package harborview.api;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import java.util.Locale;

@Controller
@RequestMapping("/")
public class HomeController {

    @RequestMapping(method =  RequestMethod.GET)
    public String index(Locale locale, Model model) {
        return "maunaloa/charts";
    }

    @RequestMapping(method =  RequestMethod.GET, path = "rapanui")
    public String rapanui(Locale locale, Model model) {
        return "rapanui/rapanui";
    }
}
