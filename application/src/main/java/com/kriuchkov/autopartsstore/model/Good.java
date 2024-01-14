package com.kriuchkov.autopartsstore.model;

import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.ToString;

import jakarta.persistence.*;
import java.util.Set;

@Data
@Entity
@Table(name = "goods")
public class Good {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "good_id")
    private Integer id;

    @Column(name = "good_name")
    private String name;

    @ToString.Exclude
    @EqualsAndHashCode.Exclude
    @OneToMany(mappedBy = "good")
    private Set<Catalogue> catalogue;
}
