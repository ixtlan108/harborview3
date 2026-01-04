package harborview.rapanui.api;

import harborview.api.response.AppStatusCode;
import harborview.api.response.DefaultResponse;
import harborview.rapanui.api.request.OptionSaleRequest;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;

import java.util.List;

@Controller
@RequestMapping("/rapanui")
public class RapanuiAPI {

    @PutMapping(value = "/demo", produces = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity<DefaultResponse> demo(@RequestBody List<OptionSaleRequest> request) {

        return ResponseEntity.ok(new DefaultResponse(AppStatusCode.OK, "HEy ok!"));

    }
}
