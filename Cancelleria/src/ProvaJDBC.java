import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.InputMismatchException;
import java.util.Scanner;

import static java.lang.System.in;
import static java.lang.System.out;

public class ProvaJDBC {
    String matr;
    static final String DB_URL = "jdbc:mysql://localhost:3306/Cancelleria";
    static final String USER = "Paolo";
    static final String PASS = "Paolo1511!!";
    Scanner sc = new Scanner(in);

    //static final String QUERY = "SELECT Nome,Cognome FROM Giudice";
    //C:/Program Files (x86)/MySQL/Connector J 8.0/mysql-connector-j-8.0.31.jar
    public static void main(String[] args) throws NoSuchAlgorithmException {
        Connection conn;
        String query;
        int scelta;
        Boolean isgiud;
        Statement stmt;
        ProvaJDBC PDB = new ProvaJDBC();
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (java.lang.ClassNotFoundException e) {
            out.println("C'è stato un problema col JDBC");
            return;
        }
        try {
            conn = DriverManager.getConnection(DB_URL, USER, PASS);
        } catch (java.sql.SQLException e) {
            out.println("C'è stato un problema con la connessione al DB, riguardare DB_URL, USER o PSW");
            return;
        }
        try {
            stmt = conn.createStatement();
        } catch (java.sql.SQLException e) {
            out.println("C'è stato un problema con la creazione dello statement");
            return;
        }
        PDB.logorepubblica();
        while (true) {
            out.println();
            out.println();
            out.println("Benvenuto nel sistema di gestione e consultazione del tribunale.");
            out.println("Inserire la propria matricola e password.");
            isgiud = PDB.login(stmt);
            lgn:
            while (true) {
                if (isgiud) {
                    out.println("Può eseguire le seguenti azioni");
                    out.println("0. Torna al login");
                    out.println("Visualizzazione fascicoli");
                    out.println("   1.  Visualizzare i fascicoli");
                    out.println("Operazioni sui verbali d'udienza");
                    out.println("   2.  Visualizzare i verbali d'udienza");
                    out.println("   3.  Inserire un nuovo verbale d'udienza");
                    out.println("   4.  Modfiicare un verbale d'udienza");
                    out.println("Operazioni sulle sentenze");
                    out.println("   5.  Visualizzare le sentenze");
                    out.println("   6.  Inserire una nuova sentenza");
                    out.println("   7.  Modificare una sentenza");
                    out.println("Visualizzazioni elementi probatori e avvocati");
                    out.println("   8.  Visualizzare dati prove documentali di un fascicolo");
                    out.println("   9.  Visualizzare dati deposizioni di un fascicolo");
                    out.println("   10. Visualizzare avvocati di un fascicolo e il loro ruolo");
                    try {
                        scelta = PDB.sc.nextInt();
                        switch (scelta) {
                            case 0 -> {
                                break lgn;
                            }
                            case 1 -> {
                                PDB.fascicoli_del_giudice(stmt);
                                System.out.println("Premere invio per continuare");
                                try {
                                    System.in.read();
                                } catch (Exception e) {
                                }
                                out.println();
                            }
                            case 2 -> {
                                PDB.verbali_del_giudice(stmt);
                                System.out.print("Premere invio per continuare");
                                try {
                                    System.in.read();
                                } catch (Exception e) {
                                }
                                out.println();
                            }
                            case 3 -> {
                                PDB.Inserisci_verbale(stmt);
                                System.out.print("Premere invio per continuare");
                                try {
                                    System.in.read();
                                } catch (Exception e) {
                                }
                                out.println();
                            }
                            case 4 -> {
                                PDB.Modifica_verbale(conn);
                                System.out.print("Premere invio per continuare");
                                try {
                                    System.in.read();
                                } catch (Exception e) {
                                }
                                out.println();
                            }
                            default -> {
                                out.println("Inserire una cifra valida");
                                try {
                                    System.in.read();
                                } catch (Exception e) {
                                }
                                out.println();
                            }
                        }
                    } catch (InputMismatchException e) {
                        out.println("!!!");
                        out.println("Inserire una cifra, non un carattere alfabetico, un simbolo o una stringa");
                        out.println("!!!");
                        PDB.sc.next();
                    }
                } else {

                }
            }
        }
    }

    void fascicoli_del_giudice(Statement stmt) {
        ResultSet rs;
        String query = "SELECT fascicolo.* FROM accede,fascicolo WHERE accede.Codmatr='" + matr + "' AND fascicolo.Rgen=accede.R_gen";
        try {
            rs = stmt.executeQuery(query);
            while (rs.next()) {
                out.println("Ruolo generale: " + rs.getString("Rgen") + " Anno: " + rs.getString("Anno") +
                        " Fase: " + rs.getString("Fase"));
                out.println();
            }
            out.println();
            out.println("--- Fine fascicoli ---");
            out.println();
        } catch (java.sql.SQLException e) {
            out.println();
            out.println("!!!");
            out.println("Errore nella query dei fascicoli del giudice");
            out.println("!!!");
            out.println();
        }
    }

    void verbali_del_giudice(Statement stmt) {
        ResultSet rs;
        String query = "SELECT verbale_udienza.* FROM accede,fascicolo,verbale_udienza WHERE accede.Codmatr='" + matr + "' AND fascicolo.Rgen=accede.R_gen AND verbale_udienza.Rgen=fascicolo.Rgen";
        try {
            rs = stmt.executeQuery(query);
            while (rs.next()) {
                out.println("ID verbale: " + rs.getInt("ID_Verbale") + " Ruolo generale: " + rs.getInt("Rgen") + " Giorno, Data e ora inserimento: " + rs.getString("Giorno_settimana") + " " + rs.getString("Data"));
                out.println("Descrizione: " + rs.getString("Descrizione"));
                out.println();
            }
            out.println();
            out.println("--- Fine verbali ---");
            out.println();
        } catch (java.sql.SQLException e) {
            out.println();
            out.println("!!!");
            out.println("Errore nella query dei verbali del giudice");
            out.println("!!!");
            out.println();
        }
    }

    Boolean login(Statement stmt) throws NoSuchAlgorithmException {
        MessageDigest mdig = MessageDigest.getInstance("SHA-256");
        boolean res;
        String psw, query;
        byte[] hash;
        lgn:
        while (true) {
            out.println("Matricola: ");
            matr = sc.next();
            out.println("Password: ");
            psw = sc.next();
            hash = mdig.digest(psw.getBytes(StandardCharsets.UTF_8));
            psw = String.format("%064x", new BigInteger(1, hash));
            ResultSet rs;
            if (matr.contains("S") || matr.contains("s")) {
                query = "SELECT Cognome FROM Giudici_login WHERE Cmatr='" + matr + "' AND Psw='" + psw + "'";
                try {
                    rs = stmt.executeQuery(query);
                    if (!rs.next()) {
                        out.println("User o psw sbagliati");
                    } else {
                        out.println("Benvenuto giudice " + rs.getString("Cognome"));
                        return true;
                    }
                } catch (java.sql.SQLException e) {
                    out.println();
                    out.println("Errore nella query del login");
                    out.println();
                }
            } else {
                query = "SELECT Cognome FROM Pfisica WHERE CF='" + matr + "' AND Cognome='" + psw + "'";
                try {
                    rs = stmt.executeQuery(query);
                    if (!rs.next()) {
                        out.println("User o psw sbagliati");
                    } else {
                        out.println("Benvenuto cancelliere " + rs.getString("Cognome"));
                        return false;
                    }
                } catch (java.sql.SQLException e) {
                    out.println("Errore nella query del login");
                }
            }
        }
    }

    void Inserisci_verbale(Statement stmt) {
        try {
            Integer Fascicolo;
            String Descrizione;
            String DML;
            out.println("Inserire la descrizione del verbale, solo dopo aver scritto tutto premere INVIO");
            Descrizione = sc.next();
            out.println("Inserire il numero di fascicolo per cui si vuole inserire ");
            //sc.next();
            Fascicolo = sc.nextInt();
            DML = "CALL Ins_Verb(" + Fascicolo + ",'" + Descrizione + "','" + matr.toUpperCase() + "')";
            stmt.executeQuery(DML);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    void Modifica_verbale(Connection con) {
        try {
            String Descrizione;
            CallableStatement cs = con.prepareCall("{call Ver_Verb(?,?,?)}");
            int Verbale;
            boolean veritas;
            do {
                out.println("Inserire il numero di verbale che si vuole modificare");
                Verbale = sc.nextInt();
                cs.setInt(1, Verbale);
                cs.setString(2, matr.toUpperCase());
                cs.registerOutParameter(3, Types.BOOLEAN);
                cs.execute();
                veritas = cs.getBoolean(3);
                if (veritas) out.println("Inserire un codice verbale corretto");
            } while (veritas);
            out.println("Inserire la descrizione del verbale, solo dopo aver scritto tutto premere INVIO");
            sc.nextLine();
            Descrizione = sc.nextLine();
            out.println(Descrizione);
            cs = con.prepareCall("{call Mod_Verb(?,?)}");
            cs.setInt(1, Verbale);
            cs.setString(2, Descrizione);
            cs.execute();
            cs.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    void logorepubblica() {
        out.println("                          (@#####@        /####%####&,                         \n" +
                "                  ,&@  ,@##%#%&####&         %##%%&%#%##%& .                    \n" +
                "                @##%.%#%%#&##%##%&              %%########%%##%%&               \n" +
                "              %#%#%%%@%&(&(#@(        ,,,.          *@&&##&%#%###@@*            \n" +
                "             @###%&%###&/    ,,,,...,,,,,,,.. ,,,,.    #%#%####%###&,           \n" +
                "        @#&,&&##&&#%##%,.  .,,,,,,,,,,,,,,,,,,,,,,,.   *(/&%#####%%#%#@*        \n" +
                "      &###&&&#%#%%##%*,,,,,,,,,,,,,,,,,/,,,,,,,,,,,,,,,,,,  @%&###%@##%##&.     \n" +
                "     &####@%%%@#&&#&.,,,,,,,,.     .,,**(,,,      ,,,,,,,,,  ####&%&###%##@%    \n" +
                "   .&#%##&#&&&&%###%,,,,,.         ,,**  /,,         .,,,,,,,%######&##%%##&,   \n" +
                "   &####&&#&#&##%#%,,,,            ,,(   ,*,            ,,,,,###%##%##%##%##&   \n" +
                "  *%#&#%*%&&##%#@*,,,              ,#     **              ,,,%###%###%&%#&#%#%* \n" +
                "  &##%#&%&@##&%(,,,,,,,,,.         #       /          .,,,,,,,,,*%&##%&#%#&%#%  \n" +
                "  @#%#&&#@#%&*,,,,*///((((((#######         (######((((((///*,,,,,/&#&&#@##%#%/ \n" +
                "  ##&#&%(#&  ,,,,,,,,/#                                 /(,,,,,,,,. &#&%#@&&&   \n" +
                "   &%&&%#/.,,,,,,,  ,,,,,#.                          (*,,,,. .,,,,,,.%##@##&&   \n" +
                " &, %@&#*.,,,,,((#        .,#,                    %,,        ..&%&*,,. &%#&@%##@\n" +
                "&##&.,%&    .,(##%%&           #               /             .&%##%    ,%%%#%##@\n" +
                "%####(/#&    %%####%          #                 #.          *###@#%    #(&#&&##&\n" +
                " &#####@(( (#%#%##%/        ,/.        .         #,         ,,&#&#/*.#&&%###%%#@\n" +
                " /#####(@&.#%%#%###,      ,,,*      #*   .%.     ./,,      ,/########%&###%###& \n" +
                "  (####%*&%%#&#%#%.,,,   ,,,%   *(,,       .,/(   /*,,   .,,,%#%##%#%&####%##@. \n" +
                "   ,%#%#&%%%%%%%##,,,,,,,,,#.#*,,,           ,,,,(,(,,,,,,,,,,,%##&#@&@##%#&%   \n" +
                "     (#&#&#%&%%&#,.,,,,,,,,,,,,,               ,,,,,*,,,,,,,.,,*%(&&(@#%&##@    \n" +
                "       /%#&&(&%#&(@  .,,,,,,,,,.               .,,,,,,,,,,  %(&#%#&(%##&#&      \n" +
                "         ,@####&%#&. ,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,. @#(&&#%&&%%&/       \n" +
                "         *&#..@#&/(@         ,,,,,,,,,,,,,,,,,,,,,.       ,@(#&#%&..%@          \n" +
                "    @%%%####@  ,@((#(&.      ,,,,    .,,,,    .,,,.      &##(#&#   /##%%%%&&    \n" +
                "    @###@%##%     .@@@((&&(&(%@(                 %&#%#@###%@&%     /##%&###&    \n" +
                "   &#**(,###&(         @@&###&####@  ,%%@@/   @##%&((&&&&&        .&#### /##@.  \n" +
                "  /&/# #(,////##@,   .#&%&&&%###(//#*(#%%###@#####%%&&%%#%     /@##,/#(#/##(#(  \n" +
                "    .&##*/#,*.(.#/#*.(/,.# ### ,####*/,#&%###%%(/## #((,##./##(/# ###(###%@,    \n" +
                "        /@####/*###*/,( % (/#, .#(###%@&@##&%@# /##*#*#.##.###.##*#/*#&#        \n" +
                "            ,&#####(#######%&&@&%&@&%  %&# *@&&&@@&%#######((#*/##%@,           \n" +
                "                 ,*.     .&&(#%%@%*            %@%##&(         ..               \n" +
                "                       *&(#%&@&                  /&&###&,                       ");
    }
}