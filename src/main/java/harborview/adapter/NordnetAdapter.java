package harborview.adapter;

import com.fasterxml.jackson.databind.ObjectMapper;
import harborview.api.nordnet.response.FindOptionResponse;
import harborview.domain.nordnet.NordnetRepository;
import harborview.domain.stockmarket.StockOptionTicker;
import harborview.domain.stockmarket.StockTicker;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

//@Component("comp2")

@Component()
public class NordnetAdapter implements NordnetRepository {
    private final Logger logger = LoggerFactory.getLogger(NordnetAdapter.class);

    private final ObjectMapper objectMapper = new ObjectMapper();

    private final HttpClient client = HttpClient.newHttpClient();

    private final String nordnetHost;

    public NordnetAdapter(@Value("${adapter.nordnet.nordnet-host}") String nordnetHost) {
        this.nordnetHost = nordnetHost;
    }

    @Override
    public FindOptionResponse findOption(StockOptionTicker ticker) {
        try {
            var uri = optionUri(ticker);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(new URI(uri))
                    .GET()
                    .build();
            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            logger.info(String.format("Found option for: %s with uri: %s", ticker.ticker(), uri));

            return objectMapper.readValue(response.body(), FindOptionResponse.class);
            /*
            {
                "payload" : {
                    "option" : {
                        "bid" : 20.0,
                        "ask" : 22.5
                    },
                    "status" : 1,
                    "msg" : "c"
                },
                "appStatusCode" : 1,
                "error" : null
            }

             */
        } catch (URISyntaxException | IOException | InterruptedException e) {
            throw new RuntimeException(e);
        }
    }

    private String getResponseFor(String uri) {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(new URI(uri))
                    .GET()
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            logger.info(String.format("Response for %s", uri));
            return response.body();
        } catch (URISyntaxException | IOException | InterruptedException e) {
            throw new RuntimeException(e);
        }
    }
    @Override
    public String calls(StockTicker ticker) {
        var uri = optionUri(ticker, true);
        return getResponseFor(uri);
    }

    /*
    Process p = new ProcessBuilder("python", "Refresh.py")
            .redirectErrorStream(true)
            .start();
p.getInputStream().transferTo(System.out);
    int rc = p.waitFor();

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class Test {

    public static void main(String... args) throws Exception {

        String[] callAndArgs = {"python3", "YourScript.py"};
        Process p = Runtime.getRuntime().exec(callAndArgs);

        BufferedReader stdInput = new BufferedReader(new InputStreamReader(p.getInputStream()));
        BufferedReader stdError = new BufferedReader(new InputStreamReader(p.getErrorStream()));

        String s;
        while ((s = stdInput.readLine()) != null) {
            //System.out.println(s);
        }

        while ((s = stdError.readLine()) != null) {
            //System.out.println(s);
        }

    }

}

     */

    @Override
    public String puts(StockTicker ticker) {
        var uri = optionUri(ticker, false);
        return getResponseFor(uri);
    }

    @Override
    public String spot(StockTicker ticker) {
        var uri = spotUri(ticker);
        return getResponseFor(uri);
    }

    private String spotUri(StockTicker ticker) {
        return String.format("%s/nordnet/spot/%d", nordnetHost, ticker.oid());
    }
    private String optionUri(StockOptionTicker ticker) {
        return String.format("%s/rapanui/stockoption/%s", nordnetHost, ticker.ticker());
    }
    private String optionUri(StockTicker ticker, boolean isCalls) {
        var ot = isCalls ? "calls" : "puts";
        return String.format("%s/nordnet/%s/%d", nordnetHost, ot, ticker.oid());
    }

        /*
    @Override
    public String demo(StockOptionTicker ticker) {
        //String uri = String.format("%s/option/YAR3A528.02X", nordnetHost);

        //var uri = optionUri(ticker);

        var uri = String.format("%s/calls/3", nordnetHost);

        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(new URI(uri))
                    .GET()
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());
            ObjectMapper objectMapper = new ObjectMapper();
            var mapped = objectMapper.readValue(response.body(), FindOptionResponse.class);
            System.out.println(mapped);

            return response.body();

        } catch (URISyntaxException | IOException | InterruptedException e) {
            throw new RuntimeException(e);
        }
       return  "" ;

    }
             */


        /*
    {
        "stock-price": {
        "h": 458.9,
                "l": 450.6,
                "c": 452.6,
                "o": 452.0,
                "unix-time": 1685113860000
    },
        "option": {
        "brEven": 0.0,
                "expiry": "2023-01-20",
                "ticker": "YAR3A528.02X",
                "days": 117,
                "ivSell": 0.1375,
                "sell": 0.6,
                "buy": 0.0,
                "ivBuy": 0.05,
                "ot": 1,
                "x": 528.02
    }

    }
     */

}
