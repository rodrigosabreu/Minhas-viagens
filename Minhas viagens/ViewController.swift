//
//  ViewController.swift
//  Minhas viagens
//
//  Created by Rodrigo Abreu on 08/11/17.
//  Copyright © 2017 Rodrigo Abreu. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var mapa: MKMapView!
    var gerenciadoLocalizacao = CLLocationManager()
    var viagem : Dictionary<String, String> = [:]
    var indiceSelecionado: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if let indice = indiceSelecionado{
            
            if indice == -1{//adicionar
                
                configuraGerenciadorLocalizacao()
                
            }else{//listar
                
                exibirLocal(viagem: viagem)
                
                exibirAnotacao( viagem: viagem )
                
                
            }
                
        }
        
        //reconhecer gestos
        let reconhecedorGesto = UILongPressGestureRecognizer(target: self, action: #selector( ViewController.marcar(gesture:) ))
        reconhecedorGesto.minimumPressDuration = 2
        
        mapa.addGestureRecognizer(reconhecedorGesto)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let local = locations.last
        
        var viagemLocal: Dictionary<String, String> = [:]
        viagemLocal = ["local":"-" , "latitude":String(describing: local!.coordinate.latitude), "longetude":String(describing: local!.coordinate.longitude)]
        
        exibirLocal(viagem: viagemLocal)
        
        
    }
    
    func exibirLocal(viagem: Dictionary<String, String>){
        
        
        
        //Exibe anotaão com os dados de endereco
        if let localViagem = viagem["local"]{
            if let latitudeS = viagem["latitude"]{
                if let longetudeS = viagem["longetude"]{
                    if let latitude = Double(latitudeS){
                        if let longetude = Double(longetudeS){
                            
                            var teste = localViagem
                            teste = teste+""
                            
                            //exibe o local onde o usuario está
                            let localizacao = CLLocationCoordinate2DMake(latitude, longetude)
                            let span = MKCoordinateSpanMake(0.01, 0.01)
                            
                            let regiao: MKCoordinateRegion = MKCoordinateRegionMake(localizacao, span)
                            self.mapa.setRegion(regiao, animated: true)
                            
                            
                            gerenciadoLocalizacao.stopUpdatingLocation()
                        }
                    }
                }
            }
        }
        
        
    }
    
   
    
    
    func exibirAnotacao(viagem: Dictionary<String, String>){
        
        //Exibe anotaão com os dados de endereco
        if let localViagem = viagem["local"]{
            if let latitudeS = viagem["latitude"]{
                if let longetudeS = viagem["longetude"]{
                    if let latitude = Double(latitudeS){
                        if let longetude = Double(longetudeS){
                            
                            //adiciona anotacao
                            let anotacao = MKPointAnnotation()
                            
                            anotacao.coordinate.latitude = latitude
                            anotacao.coordinate.longitude = longetude
                            anotacao.title = localViagem
                            
                            self.mapa.addAnnotation(anotacao)
                           
                   
                            
                            
                        }
                    }
                }
            }
        }
        
    }
    
    
    
    @objc func marcar(gesture: UIGestureRecognizer){
        
        if gesture.state == UIGestureRecognizerState.began{
            
            //Recupera as coordenadas do ponto selecionado
            let pontoSelecionado = gesture.location(in: self.mapa)
            let coordenadas = mapa.convert(pontoSelecionado, toCoordinateFrom: self.mapa)
            let localizacao = CLLocation(latitude: coordenadas.latitude, longitude: coordenadas.longitude)
            
            //recupera o endereco do ponto selecionado
            var localCompleto = "Enderço não encontrado!"
            CLGeocoder().reverseGeocodeLocation(localizacao, completionHandler: { (local, erro) in
                
                if erro == nil{
                    
                    if let dadosLocal = local?.first{
                        
                        if let nome = dadosLocal.name {
                            localCompleto = nome
                        }else{
                            if let endereco = dadosLocal.thoroughfare{
                                localCompleto = endereco
                            }
                        }
                        
                    }
                    
                    //Salvar Dados no dispositivo
                    self.viagem = ["local":localCompleto , "latitude":String(coordenadas.latitude), "longetude":String(coordenadas.longitude)]
                    ArmazenamentoDados().salvarViagem(viagem: self.viagem)
                                   
                    
                    //Exibe anotação com os dados do endereco
                    self.exibirAnotacao(viagem: self.viagem)
                    
                }else{
                    print(erro!)
                }
                
            })
            
            
        }
        
        
    }
    
    
    func configuraGerenciadorLocalizacao(){
        
        gerenciadoLocalizacao.delegate = self
        gerenciadoLocalizacao.desiredAccuracy = kCLLocationAccuracyBest
        gerenciadoLocalizacao.requestWhenInUseAuthorization()
        gerenciadoLocalizacao.startUpdatingLocation()
        
        
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedWhenInUse{
            
            let alertaController = UIAlertController(title: "Permissão de localização",
                                                     message: "Necessário permissão para o acesso à sua localização! por favor habilite.",
                                                     preferredStyle: .alert)
            
            let acaoConfiguracoes = UIAlertAction(title: "Abrir configurações", style: .default, handler: { (alertaConfiguracoes) in
                
                if let configuracoes = NSURL(string:UIApplicationOpenSettingsURLString){
                    UIApplication.shared.open(configuracoes as URL)
                }
                
            })
            
            let acaoCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
            
            alertaController.addAction(acaoConfiguracoes)
            alertaController.addAction(acaoCancelar)
            
            present(alertaController, animated: true, completion: nil)
            
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

