package harborview.api.rapanui;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/rapanui")
public class RapanuiAPI {

    @PutMapping(value = "/demo", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<AppStatus> demo(@RequestBody DemoReq request) {
        return ResponseEntity.ok(new AppStatus(0, "HEy ok!"));
    }
}
