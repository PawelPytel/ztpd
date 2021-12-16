import com.espertech.esper.common.client.EPCompiled;
import com.espertech.esper.common.client.configuration.Configuration;
import com.espertech.esper.compiler.client.CompilerArguments;
import com.espertech.esper.compiler.client.EPCompileException;
import com.espertech.esper.compiler.client.EPCompilerProvider;
import com.espertech.esper.runtime.client.*;

import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        Configuration configuration = new Configuration();
        configuration.getCommon().addEventType(KursAkcji.class);
        EPRuntime epRuntime = EPRuntimeProvider.getDefaultRuntime(configuration);
        EPDeployment deployment = compileAndDeploy(epRuntime,
                "select istream data, spolka, obrot " +
                        "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
                        "order by obrot desc limit 2, 1");
        ProstyListener prostyListener = new ProstyListener();
        for (EPStatement statement : deployment.getStatements()) {
            statement.addListener(prostyListener);
        }
        InputStream inputStream = new InputStream();
        inputStream.generuj(epRuntime.getEventService());
    }

    public static EPDeployment compileAndDeploy(EPRuntime epRuntime, String epl) {
        EPDeploymentService deploymentService = epRuntime.getDeploymentService();
        CompilerArguments args = new CompilerArguments(epRuntime.getConfigurationDeepCopy());
        EPDeployment deployment;
        try {
            EPCompiled epCompiled = EPCompilerProvider.getCompiler().compile(epl, args);
            deployment = deploymentService.deploy(epCompiled);
        } catch (EPCompileException e) {
            throw new RuntimeException(e);
        } catch (EPDeployException e) {
            throw new RuntimeException(e);
        }
        return deployment;
    }
}

//5
//EPDeployment deployment = compileAndDeploy(epRuntime,
//        "select istream data, kursZamkniecia, spolka, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                "from KursAkcji.win:ext_timed_batch(data.getTime(), 1 days)");
//6
//EPDeployment deployment = compileAndDeploy(epRuntime,
//        "select istream data, kursZamkniecia, spolka, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                "from KursAkcji(spolka in ('Honda', 'IBM', 'Microsoft')).win:ext_timed_batch(data.getTime(), 1 days)");
//7a
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream data, kursOtwarcia, kursZamkniecia, spolka " +
//                        "from KursAkcji(kursZamkniecia > kursOtwarcia).win:length(1)");
//7b
//EPDeployment deployment = compileAndDeploy(epRuntime,
//        "select istream data, kursOtwarcia, kursZamkniecia, spolka " +
//                "from KursAkcji(KursAkcji.jestNotowanieWzrostowe(kursOtwarcia, kursZamkniecia)).win:length(1)");
//8
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream data, spolka, kursZamkniecia, max(kursZamkniecia) - kursZamkniecia as roznica " +
//                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:ext_timed(data.getTime(), 7 days)");
//9
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream data, spolka, kursZamkniecia, max(kursZamkniecia) " +
//                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:ext_timed_batch(data.getTime(), 1 days)" +
//                        "having max(kursZamkniecia) = kursZamkniecia");
//10
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream max(kursZamkniecia) as maksimum " +
//                        "from KursAkcji.win:ext_timed_batch(data.getTime(), 7 days)");
//11
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream p.kursZamkniecia as kursPep, c.kursZamkniecia as kursCoc, p.data " +
//                        "from KursAkcji(spolka = 'CocaCola').win:length(1) as c join " +
//                        "KursAkcji(spolka = 'PepsiCo').win:length(1) as p " +
//                        "on c.data = p.data " +
//                        "where p.kursZamkniecia > c.kursZamkniecia");
//12
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream k.spolka, k.data, k.kursZamkniecia as kursBiezacy, k.kursZamkniecia - f.kursZamkniecia as roznica " +
//                        "from KursAkcji(spolka in ('PepsiCo', 'CocaCola')).win:length(1) as k join " +
//                        "KursAkcji(spolka in ('PepsiCo', 'CocaCola')).std:firstunique(spolka) as f " +
//                        "on k.spolka = f.spolka");
//13
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream k.spolka, k.data, k.kursZamkniecia as kursBiezacy, k.kursZamkniecia - f.kursZamkniecia as roznica " +
//                        "from KursAkcji.win:length(1) as k join " +
//                        "KursAkcji.std:firstunique(spolka) as f " +
//                        "on k.spolka = f.spolka " +
//                        "where k.kursZamkniecia > f.kursZamkniecia");
//14
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream a.data as dataA, b.data as dataB, a.spolka, a.kursOtwarcia as kursA, b.kursOtwarcia as kursB " +
//                        "from KursAkcji.win:ext_timed(data.getTime(), 7 days) as a join " +
//                        "KursAkcji.win:ext_timed(data.getTime(), 7 days) as b " +
//                        "on a.spolka = b.spolka " +
//                        "where b.kursOtwarcia - a.kursOtwarcia > 3");
//15
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream data, spolka, obrot " +
//                        "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
//                        "order by obrot desc limit 3");
//16
//        EPDeployment deployment = compileAndDeploy(epRuntime,
//                "select istream data, spolka, obrot " +
//                        "from KursAkcji(market = 'NYSE').win:ext_timed_batch(data.getTime(), 7 days) " +
//                        "order by obrot desc limit 2, 1");