import pandas as pd
import googlemaps
import time

def create_gmaps_client():
    gmaps_api_key = "AIzaSyCrFjahk30aIf9xN0sp_WiCnDWMu-Asm90"
    return googlemaps.Client(key=gmaps_api_key)


def gmaps_get_lat_long(client, address):
    gmaps_response = client.geocode(address)

    try:
        latitude = gmaps_response[0]["geometry"]["location"]['lat']
        longitude = gmaps_response[0]["geometry"]["location"]['lng']
        return [latitude, longitude]
    except:
        return [0,0]



# --------------------------------

def pontual():
    gmaps_client = create_gmaps_client()

    address = ["Rua Barão de Ladário, 566/670 - Brás, São Paulo - SP, 03010-000","Rua João Teodoro, 1200 - Brás, São Paulo - SP, 03009-000","Av. Santos Dumont, 1313 - Santana, São Paulo - SP, 02012-010","Av. Braz Leme, 1732 - Santana, São Paulo - SP, 02511-000"," Rua Mons. de Andrade, 987","Rua São Caetano, 812","Av. do Estado, 2455","Rua Piracema, 221 - Santa Teresinha, São Paulo - SP, 02460-040","Rod. Hélio Smidt, s/nº - Aeroporto, Guarulhos - SP, 07190-100","Av. Bartolomeu de Carlos, 230 - Jardim Flor da Montanha, Guarulhos - SP, 07097-420","Rod. Pres. Dutra, 225 - Vila Itapegica, Guarulhos - SP, 07034-911","Av. Guarulhos, 1823 - Vila Augusta, Guarulhos - SP, 07022-020","Av. Guarulhos, 4205 - Pte. Grande, Guarulhos - SP, 07031-001","Rua Constâncio Colalilo, 630 - Vila Augusta, Guarulhos - SP, 07024-150","Rua Palestra Italia, 214 - Perdizes, Sao Paulo - SP, 05.005-030","Rua Palestra Itália, 500 - Perdizes, São Paulo - SP, 05005-030","Rua Monte Alegre, 984 - Perdizes, São Paulo - SP, 05014-901","Praça Irmãos Karmam, 40 - Perdizes, São Paulo - SP, 01252-000","Av. Sumaré, 488 - Perdizes, São Paulo - SP, 05016-090","Av. Sumaré, 1221 - Perdizes, São Paulo - SP, 05016-110","Av. Sumaré, 535 - Perdizes, São Paulo - SP, 05016-090","Av. Dr. Gastão Vidigal, 1946 - Vila Leopoldina, São Paulo - SP, 05316-900","Av. Dra. Ruth Cardoso, 4777 - Jardim Universidade Pinheiros, São Paulo - SP, 05477-000","Rua Carlos Weber, 502 - City Lapa, São Paulo - SP, 05303-000","Av. Dr. Gastão Vidigal, 2345 - Vila Leopoldina, São Paulo - SP, 05314-001","Av. Imperatriz Leopoldina, 845 - Vila Leopoldina, São Paulo - SP, 05305-011","Av. Aricanduva, 5555 - Aricanduva, São Paulo - SP, 03527-900","Av. Aricanduva, 5555 - Aricanduva, São Paulo - SP, 03527-900","Av. Aricanduva, 5555 - Aricanduva, São Paulo - SP, 03527-900","Av. Reg. Feijó, 1739 - Vila Reg. Feijó, São Paulo - SP, 03342-000","Av. José Pinheiro Borges - Itaquera, São Paulo - SP, 08220-900"]

    for i in address:
        print(f"Processing {i}")
        print(gmaps_get_lat_long(gmaps_client, i))
        


def main():
    gmaps_client = create_gmaps_client()

    # Lendo o arquivo CSV
    address_file_name = "enderecos_condo.csv"
    df_address = pd.read_csv(address_file_name, sep = ";")


    for i in range(45000, 46000, 1000):
        time_start = time.time()

        lim_max = i
        lim_min = i-1000

        df = df_address.iloc[lim_min:lim_max,]

        # Obtendo as coordenadas
        df["coord"] = df["endereco"].apply(lambda x: gmaps_get_lat_long(gmaps_client, x))

        df = pd.concat([df, pd.DataFrame(df["coord"].to_list(), columns = ['latitude', 'longitude'], 
                                           index = df.index)], axis = 1)

        file_index = int(i/1000)
        df.to_excel(f"ederecos_condo_latlong_{file_index}.xlsx", index = False)
        
        time_delta = time.time() - time_start

        print(lim_min, lim_max, file_index, time_delta)

if __name__ == "__main__":
    #main()
    pontual()
    
